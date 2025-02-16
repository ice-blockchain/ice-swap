// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title IONSwap
 * @notice This contract enables users to swap between two ERC20 tokens at a fixed exchange rate,
 * adjusted for token decimals. The exchange rate ensures that swapping N tokens of one type
 * yields N tokens of the other type, with proper decimal scaling.
 *
 * For example, with ICE v1 (18 decimals) and ICE v2 (9 decimals):
 * - Swapping 1000 ICE v2 tokens will yield 1000 ICE v1 tokens
 * - Under the hood: 1000 * 10^9 smallest units converts to 1000 * 10^18 smallest units
 *
 * I.e. the factual numeric number of tokens is adjusted due to different decimals, while the human-readable value
 * remains the same.
 *
 * Forward Swap:
 * - Users provide `otherToken` and receive `pooledToken`.
 * - The `otherToken` is accumulated in the contract to provide liquidity for reverse swaps.
 *
 * Reverse Swap:
 * - Users provide `pooledToken` and receive `otherToken`.
 * - The `pooledToken` is accumulated in the contract to provide liquidity for forward swaps.
 *
 */
contract IONSwap is ReentrancyGuard {

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

    /// @notice Thrown when Ether is sent to the contract.
    error EtherNotAccepted();

    /**
     * @notice Initializes the contract with the specified tokens and exchange rates.
     * @param _pooledToken The token that users will receive after swapping.
     * @param _otherToken The token that users will provide for swapping.
     */
    constructor(IERC20Metadata _pooledToken, IERC20Metadata _otherToken) {

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
     * @notice Swaps a specific amount of otherToken (ICE v1) for pooledToken (ICE v2).
     *
     * @dev Handles decimal adjustment internally to maintain whole token amounts:
     * - Input: 1000 ICE v1 (1000 * 10^18 smallest units)
     * - Output: 1000 ICE v2 (1000 * 10^9 smallest units)
     * - The user receives the same number of whole tokens regardless of decimal differences
     *
     * @param _amount The amount of otherToken to swap, in smallest units (e.g., 1 token = 1 * 10^18)
     *
     * @notice Requirements:
     * - Amount must be non-zero
     * - Contract must have sufficient pooledToken balance
     * - Caller must have approved contract to spend otherToken
     *
     * @notice Emits an OnSwap event with input and output amounts
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
     * @notice Swaps a specific amount of pooledToken (ICE v2) back to otherToken (ICE v1).
     *
     * @dev Handles decimal adjustment internally to maintain whole token amounts:
     * - Input: 1000 ICE v2 (1000 * 10^9 smallest units)
     * - Output: 1000 ICE v1 (1000 * 10^18 smallest units)
     * - The user receives the same number of whole tokens regardless of decimal differences
     *
     * @param _amount The amount of pooledToken to swap, in smallest units (e.g., 1 token = 1 * 10^9)
     *
     * @notice Requirements:
     * - Amount must be non-zero
     * - Contract must have sufficient otherToken balance
     * - Caller must have approved contract to spend pooledToken
     *
     * @notice Emits an OnSwapBack event with input and output amounts
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
