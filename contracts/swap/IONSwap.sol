// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title IONSwap
 * @notice This contract enables users to swap between two ERC20 tokens at a fixed exchange rate.
 * It supports both forward swaps (from `otherToken` to `pooledToken`) and reverse swaps (from `pooledToken` back to `otherToken`).
 * The exchange considers the different decimals each token might have, ensuring a fair 1:1 exchange adjusted for decimals.
 *
 * Forward Swap:
 * - Users provide `otherToken` and receive `pooledToken`.
 * - The `otherToken` is accumulated in the contract to provide liquidity for reverse swaps.
 *
 * Reverse Swap:
 * - Users provide `pooledToken` and receive `otherToken`.
 * - The `pooledToken` is accumulated in the contract to provide liquidity for forward swaps.
 *
 * The contract owner can withdraw tokens from the contract, allowing for liquidity management and optimal utilization of assets.
 */
contract IONSwap is Ownable, ReentrancyGuard {

    /// @notice The token that users receive after swapping (e.g., ICE v2).
    IERC20 immutable public pooledToken;

    /// @notice The exchange rate for the pooledToken.
    uint256 immutable public pooledTokenRate;

    /// @notice The token that users provide for swapping (e.g., ICE v1).
    IERC20 immutable public otherToken;

    /// @notice The exchange rate for the otherToken.
    uint256 immutable public otherTokenRate;

    /**
     * @notice Emitted when a forward token swap is performed.
     * @param sender The address initiating the swap.
     * @param amountOtherTokenIn The amount of `otherToken` provided by the sender.
     * @param amountPooledTokenOut The amount of `pooledToken` received by the sender.
     */
    event OnSwap(address indexed sender, uint256 amountOtherTokenIn, uint256 amountPooledTokenOut);

    /**
     * @notice Emitted when a reverse token swap is performed.
     * @param sender The address initiating the swap-back.
     * @param amountPooledTokenIn The amount of `pooledToken` provided by the sender.
     * @param amountOtherTokenOut The amount of `otherToken` received by the sender.
     */
    event OnSwapBack(address indexed sender, uint256 amountPooledTokenIn, uint256 amountOtherTokenOut);

    /**
     * @notice Emitted when tokens are withdrawn from the contract.
     * @param token The address of the token withdrawn.
     * @param receiver The address receiving the withdrawn tokens.
     * @param amount The amount of tokens withdrawn.
     */
    event TokensWithdrawn(IERC20 indexed token, address indexed receiver, uint256 amount);

    /// @notice Thrown when provided pooled token address is the zero address.
    error InvalidPooledTokenAddress(address invalidAddress);

    /// @notice Thrown when provided other token address is the zero address.
    error InvalidOtherTokenAddress(address invalidAddress);

    /// @notice Thrown when both tokens provided are the same.
    error TokensMustBeDifferent(address pooledToken, address otherToken);

    /// @notice Thrown when the swap amount provided is zero.
    error SwapAmountZero();

    /// @notice Thrown when the calculated output amount is zero.
    error OutputAmountZero();

    /// @notice Thrown when the contract's `pooledToken` balance is insufficient for a forward swap.
    error InsufficientPooledTokenBalance();

    /// @notice Thrown when the contract's `otherToken` balance is insufficient for a reverse swap.
    error InsufficientOtherTokenBalance();

    /// @notice Thrown when the zero amount is withdrawn.
    error WithdrawAmountZero();

    /// @notice Thrown when the contract's token balance is insufficient for withdrawal.
    error InsufficientTokenBalance();

    /// @notice Thrown when the receiver address is the zero address.
    error InvalidReceiverAddress();

    /// @notice Thrown when Ether is sent to the contract.
    error EtherNotAccepted();

    /**
     * @notice Initializes the contract with the specified tokens and exchange rates.
     * @param _owner The address to be assigned as the owner of this contract (e.g. an organization's multi-sig address).
     * @param _pooledToken The token that users will receive after swapping.
     * @param _otherToken The token that users will provide for swapping.
     */
    constructor(address _owner, IERC20Metadata _pooledToken, IERC20Metadata _otherToken) Ownable(_owner) {

        if (address(_pooledToken) == address(0)) {
            revert InvalidPooledTokenAddress(address(0));
        }

        if (address(_otherToken) == address(0)) {
            revert InvalidOtherTokenAddress(address(0));
        }

        if (_pooledToken == _otherToken) {
            revert TokensMustBeDifferent(address(_pooledToken), address(_otherToken));
        }

        uint256 _pooledTokenRate = 10 ** IERC20Metadata(_pooledToken).decimals();
        uint256 _otherTokenRate = 10 ** IERC20Metadata(_otherToken).decimals();

        pooledToken = _pooledToken;
        otherToken = _otherToken;
        pooledTokenRate = _pooledTokenRate;
        otherTokenRate = _otherTokenRate;
    }

    /**
     * @notice Swaps a specific amount of `otherToken` for `pooledToken` based on the exchange rate.
     * This is the forward swap: `otherToken` -> `pooledToken`.
     * @param _amount The amount of `otherToken` to swap.
     */
    function swapTokens(uint256 _amount) external nonReentrant {

        if (_amount == 0) {
            revert SwapAmountZero();
        }

        uint256 pooledAmountOut = getPooledAmountOut(_amount);
        if (pooledAmountOut == 0) {
            revert OutputAmountZero();
        }

        if (pooledToken.balanceOf(address(this)) < pooledAmountOut) {
            revert InsufficientPooledTokenBalance();
        }

        // Transfer the `otherToken` from the sender to the contract.
        SafeERC20.safeTransferFrom(otherToken, msg.sender, address(this), _amount);

        // Transfer the equivalent amount of `pooledToken` to the caller.
        SafeERC20.safeTransfer(pooledToken, msg.sender, pooledAmountOut);

        emit OnSwap(msg.sender, _amount, pooledAmountOut);
    }

    /**
     * @notice Swaps a specific amount of `pooledToken` back to `otherToken` based on the exchange rate.
     * This is the reverse swap: `pooledToken` -> `otherToken`.
     * @param _amount The amount of `pooledToken` to swap back.
     */
    function swapTokensBack(uint256 _amount) external nonReentrant {

        if (_amount == 0) {
            revert SwapAmountZero();
        }

        uint256 otherAmountOut = getOtherAmountOut(_amount);
        if (otherAmountOut == 0) {
            revert OutputAmountZero();
        }

        if (otherToken.balanceOf(address(this)) < otherAmountOut) {
            revert InsufficientOtherTokenBalance();
        }

        // Transfer the `pooledToken` from the sender to the contract.
        SafeERC20.safeTransferFrom(pooledToken, msg.sender, address(this), _amount);

        // Transfer the equivalent amount of `otherToken` to the user.
        SafeERC20.safeTransfer(otherToken, msg.sender, otherAmountOut);

        emit OnSwapBack(msg.sender, _amount, otherAmountOut);
    }

    /**
     * @notice Calculates the amount of `pooledToken` that will be received for a given amount of `otherToken`.
     * Used in forward swaps.
     * @param _amount The amount of `otherToken`.
     * @return amountOut The corresponding amount of `pooledToken`.
     */
    function getPooledAmountOut(uint256 _amount) public view returns (uint256 amountOut) {
        amountOut = (_amount * pooledTokenRate) / otherTokenRate;
    }

    /**
     * @notice Calculates the amount of `otherToken` that will be received for a given amount of `pooledToken`.
     * Used in reverse swaps.
     * @param _amount The amount of `pooledToken`.
     * @return amountOut The corresponding amount of `otherToken`.
     */
    function getOtherAmountOut(uint256 _amount) public view returns (uint256 amountOut) {
        amountOut = (_amount * otherTokenRate) / pooledTokenRate;
    }

    /**
     * @notice Withdraws a specified amount of a token to a receiver address.
     * @dev
     *  - Only the ION Network owners add liquidity to this contract; regular users do not deposit liquidity here.
     *  - Thus, calling `withdrawLiquidity` cannot affect user funds.
     *  - Furthermore, this function is restricted to the contract owner, which is managed by the ION Network
     *    organization's multi-sig wallet, ensuring no single centralized entity controls withdrawals.
     * @param _token The ERC20 token to withdraw.
     * @param _receiver The address that will receive the tokens.
     * @param _amount The amount of tokens to withdraw.
     */
    function withdrawLiquidity(IERC20 _token, address _receiver, uint256 _amount) external onlyOwner nonReentrant {

        if (_receiver == address(0)) {
            revert InvalidReceiverAddress();
        }

        if (_amount == 0) {
            revert WithdrawAmountZero();
        }

        if (_token.balanceOf(address(this)) < _amount) {
            revert InsufficientTokenBalance();
        }

        SafeERC20.safeTransfer(_token, _receiver, _amount);

        emit TokensWithdrawn(_token, _receiver, _amount);
    }

    /**
     * @notice Returns the encoded call data for withdrawing liquidity, to be used in multi-sig transactions.
     * @param _token The ERC20 token to withdraw.
     * @param _receiver The address that will receive the tokens.
     * @param _amount The amount of tokens to withdraw.
     * @return The encoded call data for the withdrawLiquidity function.
     */
    function withdrawLiquidityGetData(
        IERC20 _token,
        address _receiver,
        uint256 _amount
    ) external pure returns (bytes memory) {
        return abi.encodeWithSelector(
            IONSwap.withdrawLiquidity.selector,
            _token,
            _receiver,
            _amount
        );
    }

    /**
     * @notice Rejects any Ether sent directly to the contract.
     * @dev This function is called when Ether is sent to the contract without any data.
     */
    receive() external payable {
        revert EtherNotAccepted();
    }

    /**
     * @notice Rejects any transaction that doesn't match a valid function signature.
     * @dev This function is called for all messages sent to this contract except plain Ether transfers
     *      (i.e., transactions with no data AND with no function specified are rejected).
     */
    fallback() external payable {
        revert EtherNotAccepted();
    }
}
