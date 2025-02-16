# ION Swap Contract (`IONSwap.sol`)

## Introduction

The **ION Swap Contract** (`IONSwap.sol`) facilitates swapping between ICE v1 (18 decimals) and ICE v2 (9 decimals) tokens. While the contract maintains a 1:1 token exchange rate (one ICE v1 token yields one ICE v2 token), it handles the decimal differences internally to ensure proper value preservation.

---

## Exchange Rate and Token Decimals

### Token Specifications
- **ICE v1**: 18 decimals
    - 1 ICE v1 token = 1 * 10^18 smallest units
- **ICE v2**: 9 decimals
    - 1 ICE v2 token = 1 * 10^9 smallest units

### How Decimal Adjustment Works

When you swap tokens:
1. Your input amount is first converted to smallest units (multiplied by 10^18 for ICE v1 or 10^9 for ICE v2)
2. The contract performs the conversion while preserving the number of **whole** tokens
3. The output is adjusted to match the decimals of the target token

For example:
- **Forward Swap** (1000 ICE v1 to ICE v2):
    - Input: 1000 * 10^18 smallest units of ICE v1
    - Output: 1000 * 10^9 smallest units of ICE v2
    - Result: You receive 1000 **whole** ICE v2 tokens

- **Reverse Swap** (1000 ICE v2 to ICE v1):
    - Input: 1000 * 10^9 smallest units of ICE v2
    - Output: 1000 * 10^18 smallest units of ICE v1
    - Result: You receive 1000 **whole** ICE v1 tokens

### Swapping Process

#### Forward Swap (`ICE v1` to `ICE v2`)

1. **Approve Tokens**:
   - Before swapping, users must approve the `IONSwap` contract to spend their `ICE v1` tokens.
   - This is done by calling the `approve` function on the `ICE v1` token contract, specifying the `IONSwap` contract address and the amount to approve.

2. **Initiate Swap**:
   - Users call the `swapTokens` function on the `IONSwap` contract, providing the amount of `ICE v1` they wish to swap.

3. **Validation and Calculation**:
   - The contract checks that the swap amount is greater than zero.
   - It calculates the equivalent amount of `ICE v2` tokens using the exchange rates.

4. **Token Transfers**:
   - **From User to Contract**:
     - Transfers the specified amount of `ICE v1` from the user's address to the `IONSwap` contract.
   - **From Contract to User**:
     - Transfers the calculated amount of `ICE v2` from the contract to the user's address.

5. **Event Emission**:
   - An `OnSwap` event is emitted, logging the swap details, including the sender's address, the amount of `ICE v1` swapped, and the amount of `ICE v2` received.

#### Reverse Swap (`ICE v2` to `ICE v1`)

1. **Approve Tokens**:
   - Before swapping back, users must approve the `IONSwap` contract to spend their `ICE v2` tokens.
   - This is done by calling the `approve` function on the `ICE v2` token contract, specifying the `IONSwap` contract address and the amount to approve.

2. **Initiate Swap Back**:
   - Users call the `swapTokensBack` function on the `IONSwap` contract, providing the amount of `ICE v2` they wish to swap back.

3. **Validation and Calculation**:
   - The contract checks that the swap-back amount is greater than zero.
   - It calculates the equivalent amount of `ICE v1` tokens using the exchange rates.

4. **Token Transfers**:
   - **From User to Contract**:
     - Transfers the specified amount of `ICE v2` from the user's address to the `IONSwap` contract.
   - **From Contract to User**:
     - Transfers the calculated amount of `ICE v1` from the contract to the user's address.

5. **Event Emission**:
   - An `OnSwapBack` event is emitted, logging the swap-back details, including the sender's address, the amount of `ICE v2` swapped, and the amount of `ICE v1` received.

---

## Using the ION Swap Contract

### Prerequisites

- **Wallet Setup**: Ensure you have a compatible Ethereum wallet (e.g., MetaMask).
- **Token Balances**:
  - For forward swaps: Sufficient balance of `ICE v1` tokens.
  - For reverse swaps: Sufficient balance of `ICE v2` tokens.
- **Contract Addresses**:
  - **IONSwap Contract Address**: The deployed address of the `IONSwap` contract.
  - **Token Addresses**:
    - `pooledToken` (`ICE v2`): The token you will receive or provide in reverse swaps.
    - `otherToken` (`ICE v1`): The token you will provide or receive in reverse swaps.

### Step-by-Step Guide

#### Forward Swap (`ICE v1` to `ICE v2`)

1. **Obtain Contract Addresses**:
   - Ensure you have the correct addresses for the `IONSwap` contract, `ICE v1`, and `ICE v2` tokens.

2. **Approve IONSwap Contract to Spend ICE v1**:
   - Call the `approve` function on the `ICE v1` token contract.
     - **Parameters**:
       - `spender`: Address of the `IONSwap` contract.
       - `amount`: Amount of `ICE v1` you wish to swap.

3. **Perform the Swap**:
   - Call the `swapTokens` function on the `IONSwap` contract.
     - **Parameter**:
       - `_amount`: Amount of `ICE v1` you wish to swap.

4. **Receive ICE v2 Tokens**:
   - After the transaction is confirmed, you will receive the equivalent amount of `ICE v2` tokens in your wallet.

5. **Check Balances**:
   - Verify that your `ICE v1` balance has decreased and your `ICE v2` balance has increased accordingly.

#### Reverse Swap (`ICE v2` to `ICE v1`)

1. **Approve IONSwap Contract to Spend ICE v2**:
   - Call the `approve` function on the `ICE v2` token contract.
     - **Parameters**:
       - `spender`: Address of the `IONSwap` contract.
       - `amount`: Amount of `ICE v2` you wish to swap back.

2. **Perform the Swap Back**:
   - Call the `swapTokensBack` function on the `IONSwap` contract.
     - **Parameter**:
       - `_amount`: Amount of `ICE v2` you wish to swap back.

3. **Receive ICE v1 Tokens**:
   - After the transaction is confirmed, you will receive the equivalent amount of `ICE v1` tokens in your wallet.

4. **Check Balances**:
   - Verify that your `ICE v2` balance has decreased and your `ICE v1` balance has increased accordingly.

### Example

Assuming:

- `ICE v2` has **9 decimals**.
- `ICE v1` has **18 decimals**.
- You want to swap **1 `ICE v1` token** (which is `1 * 10^18` due to 18 decimals).

**Forward Swap Steps**:

1. **Approve** the `IONSwap` contract to spend `1 * 10^18` units of `ICE v1`.

2. **Call `swapTokens`** with `_amount = 1 * 10^18`.

3. **Result**:

   - You will receive `1 * 10^9` units of `ICE v2` in your wallet.

**Reverse Swap Steps**:

1. **Approve** the `IONSwap` contract to spend `1 * 10^9` units of `ICE v2`.

2. **Call `swapTokensBack`** with `_amount = 1 * 10^9`.

3. **Result**:

   - You will receive `1 * 10^18` units of `ICE v1` in your wallet.

---

## Important Considerations

### Liquidity Management

- **Token Accumulation**:
  - The contract holds balances of both `ICE v1` and `ICE v2` to facilitate swaps in both directions.
- **Purpose**:
  - Allows users to swap tokens without burning, enabling reverse swaps.
  - Maintains liquidity within the contract for efficient swapping.

### Token Decimals

- **Understanding Decimals**:
  - ERC20 tokens can have varying decimals, affecting how amounts are represented.
  - Always consider the decimals when specifying amounts.
- **Calculating Amounts**:
  - Use the token's decimal places to determine the exact amount to input.
  - For example, `1` token with `18` decimals is represented as `1 * 10^18`.

### Contract Balance and Liquidity

- **Sufficient Token Balances**:
  - The contract must have enough `pooledToken` (`ICE v2`) or `otherToken` (`ICE v1`) balance to fulfill swap requests.
  - If the contract lacks sufficient tokens for a swap, the transaction will revert.
- **Replenishing Liquidity**:
  - The contract owner is responsible for maintaining adequate liquidity.
  - Users should check the contract's balances if they encounter liquidity issues.

### Ownership and Withdrawals

- **Contract Owner**:
  - The owner of the contract maintains privileges, such as withdrawing tokens for liquidity management.
- **Withdrawal Functionality**:
  - The owner can withdraw tokens from the contract using the `withdrawLiquidity` function.
  - Ensures optimal utilization of assets and maintains liquidity balance.

### Security Measures

- **Reentrancy Guard**:
  - The contract uses `nonReentrant` modifiers to prevent reentrancy attacks.
- **Validation Checks**:
  - Input amounts are validated to prevent zero-amount swaps.
  - The contract checks for sufficient token balances before executing swaps.
- **Ether Handling**:
  - The contract does not accept Ether. Any attempt to send Ether will be rejected.

### Error Handling

- **Common Errors**:
  - `SwapAmountZero`: Attempting to swap zero tokens.
  - `OutputAmountZero`: Calculated output amount is zero due to improper input.
  - `InsufficientPooledTokenBalance`: Not enough `ICE v2` in the contract for forward swaps.
  - `InsufficientOtherTokenBalance`: Not enough `ICE v1` in the contract for reverse swaps.
  - `InvalidTokenAddress`: Token address provided is zero.
  - `TokensMustBeDifferent`: The `pooledToken` and `otherToken` cannot be the same.

---

## Contract Functions Overview

### Public Functions

- **`swapTokens(uint256 _amount)`**

  - Swaps a specific amount of `otherToken` (`ICE v1`) for `pooledToken` (`ICE v2`).
  - **Parameters**:
    - `_amount`: The amount of `ICE v1` to swap.
  - **Emits**: `OnSwap` event.

- **`swapTokensBack(uint256 _amount)`**

  - Swaps a specific amount of `pooledToken` (`ICE v2`) back to `otherToken` (`ICE v1`).
  - **Parameters**:
    - `_amount`: The amount of `ICE v2` to swap back.
  - **Emits**: `OnSwapBack` event.

- **`getPooledAmountOut(uint256 _amount) → uint256`**

  - Calculates the amount of `pooledToken` you will receive for a given amount of `otherToken`.
  - **Parameters**:
    - `_amount`: The amount of `otherToken`.
  - **Returns**: Calculated amount of `pooledToken`.

- **`getOtherAmountOut(uint256 _amount) → uint256`**

  - Calculates the amount of `otherToken` you will receive for a given amount of `pooledToken`.
  - **Parameters**:
    - `_amount`: The amount of `pooledToken`.
  - **Returns**: Calculated amount of `otherToken`.

### Owner-Only Functions

- **`withdrawLiquidity(IERC20 _token, address _receiver, uint256 _amount)`**

  - Allows the contract owner to withdraw a specific amount of tokens from the contract.
  - **Parameters**:
    - `_token`: The ERC20 token to withdraw.
    - `_receiver`: The address to receive the withdrawn tokens.
    - `_amount`: The amount of tokens to withdraw.
  - **Emits**: `TokensWithdrawn` event.

- **`withdrawLiquidityGetData(IERC20 _token, address _receiver, uint256 _amount) → bytes`**

  - Returns the encoded call data for `withdrawLiquidity`, useful for initiating withdrawals in multi-sig wallets.
  - **Parameters**:
    - `_token`: The ERC20 token to withdraw.
    - `_receiver`: The address to receive the withdrawn tokens.
    - `_amount`: The amount of tokens to withdraw.
  - **Returns**: Encoded call data for `withdrawLiquidity`.

### Events

- **`OnSwap(address indexed sender, uint256 amountOtherTokenIn, uint256 amountPooledTokenOut)`**

  - Emitted when a forward swap is executed.
  - **Parameters**:
    - `sender`: Address of the user who initiated the swap.
    - `amountOtherTokenIn`: Amount of `ICE v1` swapped.
    - `amountPooledTokenOut`: Amount of `ICE v2` received.

- **`OnSwapBack(address indexed sender, uint256 amountPooledTokenIn, uint256 amountOtherTokenOut)`**

  - Emitted when a reverse swap is executed.
  - **Parameters**:
    - `sender`: Address of the user who initiated the swap-back.
    - `amountPooledTokenIn`: Amount of `ICE v2` swapped.
    - `amountOtherTokenOut`: Amount of `ICE v1` received.

- **`TokensWithdrawn(IERC20 indexed token, address indexed receiver, uint256 amount)`**

  - Emitted when tokens are withdrawn from the contract by the owner.
  - **Parameters**:
    - `token`: The token withdrawn.
    - `receiver`: The address that received the tokens.
    - `amount`: The amount of tokens withdrawn.

---

## Frequently Asked Questions (FAQ)

### 1. **Can I swap both ways between `ICE v1` and `ICE v2`?**

Yes. The `IONSwap` contract supports both forward swaps (`ICE v1` to `ICE v2`) and reverse swaps (`ICE v2` to `ICE v1`).

### 2. **Is there any burning of tokens during the swap?**

No. In the updated contract, tokens are not burned during the swap process. Instead, tokens provided by users are accumulated within the contract to maintain liquidity for swaps in both directions.

### 3. **What happens if the contract doesn't have enough tokens to fulfill my swap?**

If the contract lacks sufficient `ICE v2` or `ICE v1` tokens to fulfill your swap request, the transaction will revert. You can try swapping a smaller amount or wait until the contract's liquidity is replenished.

### 4. **Do I need to approve the contract before swapping?**

Yes. Before performing a swap, you must approve the `IONSwap` contract to spend the amount of tokens you wish to swap.

### 5. **Can the contract owner withdraw tokens from the contract?**

Yes. The contract owner can withdraw tokens using the `withdrawLiquidity` function. This functionality is intended for liquidity management and is controlled by a multi-signature wallet to ensure security.

### 6. **Can I send Ether to this contract?**

No. The `IONSwap` contract does not accept Ether. Any attempt to send Ether will result in the transaction being reverted.

---
