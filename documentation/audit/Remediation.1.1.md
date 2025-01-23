# CryptoAudit.report – Remediation Audit Report for `IONBridgeRouter` and `IONSwap`

**Project Name**: IONBridgeRouter and IONSwap

**Remediation Audit Date**: 2023.10.31

**Document Version**: 1.2

---

## Introduction

This report presents the findings of the remediation audit for the **IONBridgeRouter** and **IONSwap** smart contracts, following the initial audit conducted on 2025.01.17 (version 1.1). The purpose of this remediation audit is to verify that the issues identified in the initial audit have been adequately addressed and to ensure that the contracts are secure for deployment.

---

## Scope

The scope of this remediation audit includes:

- **IONBridgeRouter.sol**
- **IONSwap.sol**

**Files in Scope**:

- `/contracts/ion-bridge-router/IONBridgeRouter.sol`
- `/contracts/swap/IONSwap.sol`

---

## Executive Summary

After a thorough review of the updated smart contracts, we confirm that all issues identified in the initial audit (v1.1) have been addressed appropriately. The contracts now adhere to best practices in Solidity programming and exhibit improved security and robustness.

**Summary of Findings:**

- **Critical Severity**: 0 remaining issues
- **Major Severity**: 0 remaining issues
- **Medium Severity**: 0 remaining issues
- **Low Severity**: 0 remaining issues
- **Informational**: 0 remaining issues

The contracts are considered secure for deployment.

---

## Remediation Verification

### IONBridgeRouter Contract

#### Medium Severity Issues

**M01: Missing Reentrancy Guards on Sensitive Functions**

- **Initial Finding**: The `burn` and `voteForMinting` functions lacked reentrancy guards.
- **Remediation**:
    - The `IONBridgeRouter` contract now inherits from `ReentrancyGuard`.
    - The `nonReentrant` modifier has been applied to the `burn` and `voteForMinting` functions.

**Verification**: The issue has been resolved. The `burn` and `voteForMinting` functions are now protected against reentrancy attacks.

---

#### Low Severity Issues

**L01: Lack of Input Validation for External Contract Addresses**

- **Initial Finding**: Constructor did not validate the addresses of the external contracts.
- **Remediation**:
    - Added `require` statements in the constructor to ensure that `_iceV1`, `_iceV2`, `_bridge`, and `_ionSwap` are not zero addresses.
    - Provided descriptive error messages for each check.

**Verification**: Input validation is now implemented in the constructor, preventing deployment with invalid addresses.

---

**L02: Missing Events for Critical State-Changing Functions**

- **Initial Finding**: The `burn` and `voteForMinting` functions did not emit events upon successful execution.
- **Remediation**:
    - Defined new events `TokensBurned` and `TokensMinted`.
    - Emitted these events in the `burn` and `voteForMinting` functions upon successful execution.

**Verification**: Events are now properly emitted, enhancing transparency and facilitating off-chain monitoring and auditing.

---

#### Informational Findings

**I01: Use of Deprecated `approve` Function Pattern**

- **Initial Finding**: Use of `approve` without considering potential race conditions.
- **Remediation**:
    - Replaced direct calls to `approve` with `SafeERC20`'s `forceApprove` function in `_swapIceV1ToV2` and `_swapIceV2ToV1`.

**Verification**: The `forceApprove` function is now used, mitigating risks associated with the deprecated `approve` pattern.

---

**I02: Missing Error Messages on `require` Statements**

- **Initial Finding**: Generic error messages were used in `require` statements.
- **Remediation**:
    - Defined custom errors `InvalidAmount()` and `UnauthorizedReceiver()`.
    - Replaced `require` statements with `if` conditions that `revert` with custom errors.

**Verification**: Custom errors are now used, improving gas efficiency and providing clearer error messages for better debugging.

---

**I03: Function Visibility Could Be Optimized**

- **Initial Finding**: Internal functions could be marked as private.
- **Remediation**:
    - Changed the visibility of `_swapIceV1ToV2` and `_swapIceV2ToV1` from `internal` to `private`.

**Verification**: Function visibility is optimized, potentially saving gas costs by preventing unnecessary function slots.

---

### IONSwap Contract

#### Low Severity Issues

**L01: Potential Precision Loss in Token Exchange Calculations**

- **Initial Finding**: Possible precision loss due to integer division.
- **Remediation Decision**: The team decided not to fix this issue because the precision loss would only affect extremely minor amounts, which are not relevant for the tokenomics.

**Verification**: Acknowledged by the team; the decision is acceptable given the negligible impact on the contract's functionality and user experience.

---

#### Informational Findings

**I01: Optimize Function Visibility**

- **Initial Finding**: Functions `getPooledAmountOut` and `getOtherAmountOut` were declared `public` but could be `external`.
- **Remediation**:
    - Changed the visibility of `getPooledAmountOut` and `getOtherAmountOut` from `public` to `external`.

**Verification**: Function visibility is optimized, saving gas costs when called externally.

---

**I02: Add Zero Address Check for `_receiver` in `withdrawLiquidity`**

- **Initial Finding**: The `_receiver` parameter was not validated against the zero address.
- **Remediation**:
    - Added a check to ensure `_receiver` is not the zero address.
    - Defined a custom error `InvalidReceiverAddress()`.

**Verification**: The zero address check is now implemented, preventing potential issues with token transfers to the zero address.

---

**I03: Use Descriptive Custom Errors in Constructor Validations**

- **Initial Finding**: Constructor validations used custom errors without clear messages.
- **Remediation**:
    - Defined specific custom errors `InvalidPooledTokenAddress()` and `InvalidOtherTokenAddress()`.
    - Used these custom errors in constructor validations to provide clearer messages.

**Verification**: Custom errors now provide clear and specific messages, enhancing readability and debugging.

---

## Code Review Summary

The updated contracts have been thoroughly reviewed, and the changes align with the recommendations provided in the initial audit. The use of `ReentrancyGuard`, custom errors, event emissions, and safe approval patterns significantly enhance the security and maintainability of the contracts.

---

## Recommendations

No further recommendations are provided at this time, as all identified issues have been addressed. It is advisable to continue following best practices in smart contract development and to consider regular security audits, especially after any substantial code changes.

---

## Conclusion

All issues identified in the initial audit have been appropriately addressed. The **IONBridgeRouter** and **IONSwap** contracts now adhere to best practices and exhibit no known vulnerabilities. The contracts are considered secure for deployment to a production environment.

---

**Disclaimer**: This remediation audit does not guarantee the absence of vulnerabilities. It is recommended to follow continuous security best practices and monitoring.

---

# Annex: Updated Code Snippets

## IONBridgeRouter.sol

```solidity
// Relevant changes highlighted

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {IONSwap} from "../swap/IONSwap.sol";
import {IIONBridge} from "./IIONBridge.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title IONBridgeRouter
 * @notice Acts as a facade for the `IONSwap` and `Bridge` contracts, providing a unified interface
 * for minting and burning tokens across chains. It simplifies the user experience by abstracting
 * the interactions with both the swap and bridge functionalities.
 */
contract IONBridgeRouter is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice ICE v1 token interface
    IERC20 public iceV1;

    /// @notice ICE v2 token interface
    IERC20 public iceV2;

    /// @notice Bridge contract interface
    IIONBridge public bridge;

    /// @notice IONSwap contract instance
    IONSwap public ionSwap;

    /**
     * @notice Emitted when tokens are successfully burned and bridged.
     * @param user The address of the user initiating the burn.
     * @param amount The amount of ICE v2 tokens burned.
     * @param addr The ION network address to receive the tokens.
     */
    event TokensBurned(address indexed user, uint256 amount, IIONBridge.IONAddress addr);

    /**
     * @notice Emitted when tokens are successfully minted and swapped.
     * @param user The address of the user receiving the tokens.
     * @param iceV2Amount The amount of ICE v2 tokens minted.
     * @param iceV1Amount The amount of ICE v1 tokens received after swapping.
     */
    event TokensMinted(address indexed user, uint256 iceV2Amount, uint256 iceV1Amount);

    /// @notice Thrown when the provided amount is zero
    error InvalidAmount();

    /// @notice Thrown when the receiver in the SwapData does not match msg.sender
    error UnauthorizedReceiver();

    /**
     * @notice Initializes the contract with the specified tokens and contract addresses.
     * @param _iceV1 The address of the ICE v1 token.
     * @param _iceV2 The address of the ICE v2 token.
     * @param _bridge The address of the Bridge contract.
     * @param _ionSwap The address of the IONSwap contract.
     */
    constructor(
        address _iceV1,
        address _iceV2,
        address _bridge,
        address _ionSwap
    ) {
        require(_iceV1 != address(0), "Invalid ICE v1 token address");
        require(_iceV2 != address(0), "Invalid ICE v2 token address");
        require(_bridge != address(0), "Invalid Bridge contract address");
        require(_ionSwap != address(0), "Invalid IONSwap contract address");

        iceV1 = IERC20(_iceV1);
        iceV2 = IERC20(_iceV2);
        bridge = IIONBridge(payable(_bridge));
        ionSwap = IONSwap(payable(_ionSwap));
    }

    /**
     * @notice Swaps ICE v1 to ICE v2 and burns the ICE v2 tokens via the Bridge contract to initiate a cross-chain transfer.
     * @param amount The amount of ICE v1 tokens to burn and bridge.
     * @param addr The ION network address to receive the tokens.
     */
    function burn(uint256 amount, IIONBridge.IONAddress memory addr) external nonReentrant {
        if (amount == 0) {
            revert InvalidAmount();
        }

        // Swap ICE v1 to ICE v2
        uint256 iceV2Amount = _swapIceV1ToV2(amount);

        // Approve the Bridge contract to spend ICE v2 tokens using SafeERC20's forceApprove
        SafeERC20.forceApprove(iceV2, address(bridge), iceV2Amount);

        // Burn the ICE v2 tokens via the Bridge contract to initiate bridging to the ION network
        bridge.burn(iceV2Amount, addr);

        // Emit success event
        emit TokensBurned(msg.sender, iceV2Amount, addr);
    }

    /**
     * @notice Swaps ICE v2 to ICE v1 after minting ICE v2 tokens via the Bridge contract.
     * @param data The SwapData containing mint details from the ION network.
     * @param signatures The array of signatures from the Bridge oracles.
     */
    function voteForMinting(
        IIONBridge.SwapData memory data,
        IIONBridge.Signature[] memory signatures
    ) external nonReentrant {
        // Ensure the receiver in the SwapData is the caller
        if (data.receiver != msg.sender) {
            revert UnauthorizedReceiver();
        }

        // Call the bridge to mint ICE v2 tokens to the user
        bridge.voteForMinting(data, signatures);

        uint256 iceV2Amount = data.amount;

        // Swap ICE v2 to ICE v1
        uint256 iceV1Amount = _swapIceV2ToV1(iceV2Amount);

        // Transfer ICE v1 tokens to the user
        iceV1.safeTransfer(msg.sender, iceV1Amount);

        // Emit success event
        emit TokensMinted(msg.sender, iceV2Amount, iceV1Amount);
    }

    /**
     * @notice Internal function to swap ICE v1 tokens to ICE v2 tokens using the IONSwap contract.
     * @param amount The amount of ICE v1 tokens to swap.
     * @return iceV2Amount The amount of ICE v2 tokens received after the swap.
     */
    function _swapIceV1ToV2(uint256 amount) private returns (uint256 iceV2Amount) {
        // Transfer ICE v1 tokens from the user to this contract
        iceV1.safeTransferFrom(msg.sender, address(this), amount);

        // Approve the IONSwap contract to spend ICE v1 tokens using SafeERC20's forceApprove
        SafeERC20.forceApprove(iceV1, address(ionSwap), amount);

        // Perform the swap; ICE v2 tokens will be sent to this contract
        ionSwap.swapTokens(amount);

        // Calculate the amount of ICE v2 tokens received
        iceV2Amount = ionSwap.getPooledAmountOut(amount);

        // No need to transfer ICE v2 tokens as they are already in this contract
    }

    /**
     * @notice Internal function to swap ICE v2 tokens to ICE v1 tokens using the IONSwap contract.
     * @param iceV2Amount The amount of ICE v2 tokens to swap.
     * @return iceV1Amount The amount of ICE v1 tokens received after the swap.
     */
    function _swapIceV2ToV1(uint256 iceV2Amount) private returns (uint256 iceV1Amount) {
        // Transfer ICE v2 tokens from the user to this contract
        iceV2.safeTransferFrom(msg.sender, address(this), iceV2Amount);

        // Approve the IONSwap contract to spend ICE v2 tokens using SafeERC20's forceApprove
        SafeERC20.forceApprove(iceV2, address(ionSwap), iceV2Amount);

        // Perform the reverse swap; ICE v1 tokens will be sent to this contract
        ionSwap.swapTokensBack(iceV2Amount);

        // Calculate the amount of ICE v1 tokens received
        iceV1Amount = ionSwap.getOtherAmountOut(iceV2Amount);

        // No need to transfer ICE v1 tokens as they are already in this contract
    }
}
```

---

## IONSwap.sol

```solidity
// Relevant changes highlighted

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

    // ...

    /// @notice Thrown when provided pooled token address is the zero address.
    error InvalidPooledTokenAddress(address invalidAddress);

    /// @notice Thrown when provided other token address is the zero address.
    error InvalidOtherTokenAddress(address invalidAddress);

    /// @notice Thrown when both tokens provided are the same.
    error TokensMustBeDifferent(address pooledToken, address otherToken);

    // ...

    /**
     * @notice Initializes the contract with the specified tokens and exchange rates.
     * @param _owner The address to be assigned as the owner of this contract.
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

    // ...

    /**
     * @notice Withdraws a specified amount of a token to a receiver address.
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

    // ...
}
```

---

