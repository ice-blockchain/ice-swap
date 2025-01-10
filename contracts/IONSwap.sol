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
 * The primary function is to exchange tokens at a 1:1 rate, considering the different decimals each token might have.
 * This means that the contract adjusts for the tokens' decimal places to ensure a fair 1:1 exchange.
 *
 * The fixed exchange rate is an expected behavior of this contract, providing predictability and simplicity for users.
 * It's designed to handle tokens with different decimals seamlessly, ensuring that swapping 1 unit of `otherToken`
 * will yield 1 unit of `pooledToken`, adjusted for their respective decimal representations.
 *
 * Additionally, the contract owner retains the ability to withdraw pooled tokens.
 * This feature allows the owner to move liquidity to other pools or platforms as needed,
 * providing flexibility in liquidity management and ensuring optimal utilization of the pooled assets.
 *
 * Users interact with the contract by calling the `swapTokens` function, supplying the amount of `otherToken`
 * they wish to swap. The contract then calculates the equivalent amount of `pooledToken` based on the fixed exchange rate
 * and transfers it back to the user.
 *
 * Security measures are in place, including validations on input amounts and balance checks,
 * to ensure the contract operates reliably and securely.
 */
contract IONSwap is Ownable, ReentrancyGuard {

    /// @notice The token that users receive after swapping.
    IERC20 immutable public pooledToken;

    /// @notice The exchange rate for the pooledToken.
    uint256 immutable public pooledTokenRate;

    /// @notice The token that users provide for swapping.
    IERC20 immutable public otherToken;

    /// @notice The exchange rate for the otherToken.
    uint256 immutable public otherTokenRate;

    /**
     * @notice Emitted when a token swap is performed.
     * @param sender The address initiating the swap.
     * @param amountOtherTokenIn The amount of `otherToken` provided by the sender.
     * @param amountPooledTokenOut The amount of `pooledToken` received by the sender.
     */
    event OnSwap(address indexed sender, uint256 amountOtherTokenIn, uint256 amountPooledTokenOut);

    /**
     * @notice Emitted when tokens are withdrawn from the contract.
     * @param token The address of the token withdrawn.
     * @param receiver The address receiving the withdrawn tokens.
     * @param amount The amount of tokens withdrawn.
     */
    event TokensWithdrawn(IERC20 indexed token, address indexed receiver, uint256 amount);

    /// @notice Thrown when a provided token address is the zero address.
    error InvalidTokenAddress();

    /// @notice Thrown when a provided exchange rate is zero.
    error InvalidExchangeRate();

    /// @notice Thrown when both tokens provided are the same.
    error TokensMustBeDifferent();

    /// @notice Thrown when the swap amount provided is zero.
    error SwapAmountZero();

    /// @notice Thrown when the calculated output amount is zero.
    error OutputAmountZero();

    /// @notice Thrown when the contract's `pooledToken` balance is insufficient for the swap.
    error InsufficientPooledTokenBalance();

    /// @notice Thrown when the zero amount is withdrawn.
    error WithdrawAmountZero();

    /// @notice Thrown when the contract's token balance is insufficient for withdrawal.
    error InsufficientTokenBalance();

    /// @notice Thrown when Ether is sent to the contract.
    error EtherNotAccepted();

    /**
     * @notice Initializes the contract with the specified tokens and exchange rates.
     *
     * `_pooledToken` is the token that users will receive after swapping. This value is intentionally hard-coded and should not be changed.
     * `_otherToken` is the token that users will provide for swapping. This value is intentionally hard-coded and should not be changed.
     */
    constructor() Ownable(msg.sender) {

        IERC20Metadata _pooledToken = IERC20Metadata(0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874);
        IERC20Metadata _otherToken = IERC20Metadata(0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5);

        if (address(_pooledToken) == address(0) || address(_otherToken) == address(0)) {
            revert InvalidTokenAddress();
        }

        if (_pooledToken == _otherToken) {
            revert TokensMustBeDifferent();
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
     * @param _amount The amount of `otherToken` to swap.
     */
    function swapTokens(uint256 _amount) external nonReentrant {

        if (_amount == 0) {
            revert SwapAmountZero();
        }

        uint256 pooledAmountOut = getAmountOut(_amount);
        if (pooledAmountOut == 0) {
            revert OutputAmountZero();
        }

        if (pooledToken.balanceOf(address(this)) < pooledAmountOut) {
            revert InsufficientPooledTokenBalance();
        }

        // Transfer the `otherToken` to the contract.
        SafeERC20.safeTransferFrom(otherToken, msg.sender, address(this), _amount);

        // Burn the received `otherToken` to prevent liquidity accumulation.
        _burnOtherToken(_amount);

        // Transfer the equivalent amount of `pooledToken` to the user.
        SafeERC20.safeTransfer(pooledToken, msg.sender, pooledAmountOut);

        emit OnSwap(msg.sender, _amount, pooledAmountOut);
    }

    /**
     * @notice Pseudo-burns the specified amount of `otherToken` by transferring it to a burn address.
     * @param _amount The amount of `otherToken` to burn.
     */
    function _burnOtherToken(uint256 _amount) internal {
        address burnAddress = address(0xdead);
        SafeERC20.safeTransfer(otherToken, burnAddress, _amount);
    }

    /**
     * @notice Calculates the amount of `pooledToken` that will be received for a given amount of `otherToken`.
     * @param _amount The amount of `otherToken`.
     * @return amountOut The corresponding amount of `pooledToken`.
     */
    function getAmountOut(uint256 _amount) public view returns (uint256 amountOut) {
        amountOut = _amount * pooledTokenRate / otherTokenRate;
    }

    /**
     * @notice Withdraws a specified amount of a token to a receiver address.
     * @dev Can only be called by the contract owner.
     * @param _token The ERC20 token to withdraw.
     * @param _receiver The address that will receive the tokens.
     * @param _amount The amount of tokens to withdraw.
     */
    function withdraw(IERC20 _token, address _receiver, uint256 _amount) external onlyOwner nonReentrant {

        if (_amount == 0) {
            revert WithdrawAmountZero();
        }

        if (_token.balanceOf(address(this)) < _amount) {
            revert InsufficientTokenBalance();
        }

        SafeERC20.safeTransfer(_token, _receiver, _amount);

        emit TokensWithdrawn(_token, _receiver, _amount);
    }

    receive() external payable {
        revert EtherNotAccepted();
    }

    fallback() external payable {
        revert EtherNotAccepted();
    }
}
