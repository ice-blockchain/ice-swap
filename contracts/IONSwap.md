# ION Swap Contract (`IONSwap.sol`)

## Introduction

The **ION Swap Contract** (`IONSwap.sol`) is a smart contract designed to facilitate the swapping of tokens between two ERC20 tokens at a fixed exchange rate (specifically for swapping the old `ICE` with the new `ICE` token). This contract is particularly useful when dealing with tokens that have different decimal places, ensuring a fair and predictable `1:1` exchange adjusted for their respective decimal representations.

To maintain liquidity balance and prevent the accumulation of `ICE` tokens within the contract, the `IONSwap` contract implements a burn mechanism. During the swap process, the `ICE` tokens (`otherToken`) provided by the user are burned, effectively removing them from circulation and ensuring the liquidity remains balanced.

The contract provides a simple, secure, and efficient method for users to exchange tokens without the need for complex trading platforms or intermediaries. It handles the calculations necessary to adjust for token decimals and incorporates the burn mechanism, allowing users to swap tokens seamlessly.

---

## How the Swap Works

### Exchange Rate Adjustment

- **Fixed `1:1` Exchange Rate**: The contract swaps tokens at a `1:1` rate, adjusted for the different decimals of each token.
- **Token Decimals**:
  - **Pooled Token (`pooledToken`)**: The token users receive after swapping (e.g., `ICE` v2).
  - **Other Token (`otherToken`)**: The token users provide for swapping (e.g., `ICE` v1).
- **Rate Calculation**:
  - The contract calculates the exchange rate based on the decimals of each token.
  - It ensures that the value of tokens swapped is equivalent when adjusted for their decimals.

### Decimals Adjustment Example

If `pooledToken` has **9 decimals** and `otherToken` has **18 decimals**:

- **Rates**:
  - `pooledTokenRate = 10^9`
  - `otherTokenRate = 10^18`
- **Swap Calculation**:
  - Swapping **1 * 10^18** units of `otherToken` will yield **1 * 10^9** units of `pooledToken`.

### Swapping Process

1. **Approve Tokens**:
   - Before swapping, users must approve the `IONSwap` contract to spend their `otherToken`.
   - This is done by calling the `approve` function on the `otherToken` contract, specifying the `IONSwap` contract address and the amount to approve.

2. **Initiate Swap**:
   - Users call the `swapTokens` function on the `IONSwap` contract, providing the amount of `otherToken` they wish to swap.

3. **Validation and Calculation**:
   - The contract checks that the swap amount is greater than zero.
   - It calculates the equivalent amount of `pooledToken` using the exchange rates.

4. **Token Transfer and Burning**:
   - **From User to Contract**:
     - Transfers the specified amount of `otherToken` from the user's address to the `IONSwap` contract.
   - **Burning `otherToken`**:
     - The `otherToken` received by the contract is immediately burned by sending it to the burn address (`0xdead`).
     - This prevents the accumulation of `otherToken` within the contract and helps balance liquidity.
   - **From Contract to User**:
     - Transfers the calculated amount of `pooledToken` from the contract to the user's address.

5. **Event Emission**:
   - An `OnSwap` event is emitted, logging the swap details, including the sender's address, the amount of `otherToken` swapped and burned, and the amount of `pooledToken` received.

---

## Using the ION Swap Contract

### Prerequisites

- **Wallet Setup**: Ensure you have a compatible Ethereum wallet (e.g., MetaMask).
- **Token Balances**:
  - Sufficient balance of `otherToken` (`ICE`) to swap.
  - Ability to interact with ERC20 tokens.

### Step-by-Step Guide

1. **Obtain Contract Addresses**:
   - **IONSwap Contract Address**: The deployed address of the `IONSwap` contract.
   - **Token Addresses**:
     - `pooledToken` (`ICE` v2): The token you will receive.
     - `otherToken` (`ICE` v1): The token you will provide.

2. **Approve IONSwap Contract**:
   - Call the `approve` function on the `otherToken` contract.
     - **Parameters**:
       - `spender`: Address of the `IONSwap` contract.
       - `amount`: Amount of `otherToken` you wish to swap.
   - This allows the `IONSwap` contract to transfer `otherToken` on your behalf.

3. **Perform the Swap**:
   - Call the `swapTokens` function on the `IONSwap` contract.
     - **Parameter**:
       - `_amount`: Amount of `otherToken` you wish to swap.
   - Ensure you input the correct amount, considering the token's decimals.

4. **Receive Pooled Tokens**:
   - Upon successful execution:
     - **You will receive**: The calculated amount of `pooledToken` (`ICE` v2) in your wallet.
     - **Your `otherToken` is burned**: The `otherToken` amount will be deducted from your balance, transferred to the contract, and then burned.
   - The burn mechanism helps maintain liquidity balance by reducing the circulating supply of `otherToken`.

5. **Check Balances**:
   - Verify your wallet's token balances to confirm the swap was successful.
   - You can also view the transaction details to confirm the burning of `otherToken`.

### Example

Assuming:

- `pooledToken` (`ICE` v2) has **9 decimals**.
- `otherToken` (`ICE` v1) has **18 decimals**.
- You want to swap **1 `ICE` token** (which is `1 * 10^18` due to 18 decimals).

**Steps**:

1. **Approve** the `IONSwap` contract to spend `1 * 10^18` units of `ICE`.

2. **Call `swapTokens`** with `_amount = 1 * 10^18`.

3. **Result**:

   - You will receive `1 * 10^9` units of `ICE` v2 in your wallet.
   - The `1 * 10^18` units of `ICE` you provided are burned, reducing the total supply of `ICE`.

---

## Important Considerations

### Burn Mechanism and Liquidity Balance

- **Burning `otherToken`**:
  - The `IONSwap` contract burns all `otherToken` (`ICE`) received during swaps.
  - Burning is achieved by transferring the `otherToken` to a burn address (`0xdead`).
- **Purpose**:
  - Prevents the accumulation of `otherToken` within the contract.
  - Helps maintain liquidity balance between the two tokens.
  - Reduces the circulating supply of `otherToken`, potentially impacting its value.

### Token Decimals

- **Understanding Decimals**:
  - ERC20 tokens can have varying decimals, affecting how amounts are represented.
  - Always consider the decimals when specifying amounts.
- **Calculating Amounts**:
  - Use the token's decimal places to determine the exact amount to input.
  - For example, `1` token with `18` decimals is represented as `1 * 10^18`.

### Contract Balance and Liquidity

- **Sufficient Pooled Tokens**:
  - The contract must have enough `pooledToken` (`ICE` v2) balance to fulfill swap requests.
  - If the contract lacks sufficient `pooledToken`, the swap will fail.
- **Replenishing Pooled Tokens**:
  - The contract owner is responsible for maintaining adequate `pooledToken` liquidity.
  - Users should check the contract's balance if they encounter liquidity issues.

### Ownership and Withdrawals

- **Contract Owner**:
  - The owner of the contract maintains certain privileges, such as withdrawing tokens.
- **Withdrawal Functionality**:
  - The owner can withdraw tokens from the contract using the `withdraw` function.
  - This allows for liquidity management and ensures optimal utilization of assets.

### Security Measures

- **Burn Address Verification**:
  - The burn address used is `0xdead`, a widely recognized burn address.
  - Users can verify the burn transactions on the blockchain.
- **Reentrancy Guard**:
  - The contract uses `nonReentrant` modifiers to prevent reentrancy attacks.
- **Validation Checks**:
  - Input amounts are validated to prevent zero-amount swaps.
  - The contract checks for sufficient `pooledToken` balance before executing swaps.
- **Ether Handling**:
  - The contract does not accept Ether. Any attempt to send Ether will be rejected.

### Error Handling

- **Common Errors**:
  - `SwapAmountZero`: Attempting to swap zero tokens.
  - `OutputAmountZero`: Calculated output amount is zero due to improper input.
  - `InsufficientPooledTokenBalance`: The contract doesn't have enough `pooledToken` to fulfill the swap.
  - `InvalidTokenAddress`: Token address provided is zero.
  - `TokensMustBeDifferent`: The `pooledToken` and `otherToken` cannot be the same.

---

## Contract Functions Overview

### Public Functions

- **`swapTokens(uint256 _amount)`**

  - Swaps a specific amount of `otherToken` for `pooledToken`, burning the `otherToken` in the process.
  - **Parameters**:
    - `_amount`: The amount of `otherToken` to swap.
  - **Emits**: `OnSwap` event.

- **`getAmountOut(uint256 _amount) → uint256`**

  - Calculates the amount of `pooledToken` you will receive for a given amount of `otherToken`.
  - **Parameters**:
    - `_amount`: The amount of `otherToken`.
  - **Returns**: Calculated amount of `pooledToken`.

### Owner-Only Functions

- **`withdraw(IERC20 _token, address _receiver, uint256 _amount)`**

  - Allows the contract owner to withdraw a specific amount of tokens from the contract.
  - **Parameters**:
    - `_token`: The ERC20 token to withdraw.
    - `_receiver`: The address to receive the withdrawn tokens.
    - `_amount`: The amount of tokens to withdraw.
  - **Emits**: `TokensWithdrawn` event.

### Internal Functions

- **`_burnOtherToken(uint256 _amount)`**

  - Internal function that burns the specified amount of `otherToken` by transferring it to the burn address.
  - **Parameters**:
    - `_amount`: The amount of `otherToken` to burn.

### Events

- **`OnSwap(address indexed sender, uint256 amountOtherTokenIn, uint256 amountPooledTokenOut)`**

  - Emitted when a swap is executed.
  - **Parameters**:
    - `sender`: Address of the user who initiated the swap.
    - `amountOtherTokenIn`: Amount of `otherToken` swapped and burned.
    - `amountPooledTokenOut`: Amount of `pooledToken` received.

- **`TokensWithdrawn(IERC20 indexed token, address indexed receiver, uint256 amount)`**

  - Emitted when tokens are withdrawn from the contract by the owner.
  - **Parameters**:
    - `token`: The token withdrawn.
    - `receiver`: The address that received the tokens.
    - `amount`: The amount of tokens withdrawn.

---

## Frequently Asked Questions (FAQ)

### 1. **Why are my `otherToken` tokens burned during the swap?**

Burning the `otherToken` (`ICE`) during the swap prevents the accumulation of these tokens within the contract, helping to maintain liquidity balance. It effectively reduces the circulating supply of `otherToken`, which can have positive economic impacts on the token's value.

### 2. **Can I swap any two tokens using this contract?**

No. The tokens are predetermined at the time of contract deployment. The `pooledToken` (`ICE` v2) and `otherToken` (`ICE` v1) are set in the constructor and cannot be changed later.

### 3. **What happens if I try to swap more tokens than I have approved?**

The transaction will fail. You must approve the `IONSwap` contract to spend the amount of `otherToken` you wish to swap.

### 4. **What if the contract runs out of `pooledToken`?**

If the contract does not have enough `pooledToken` (`ICE v2`) to fulfill your swap, the transaction will revert. You can try swapping a smaller amount or wait until the contract is replenished by the owner.

### 5. **Can I retrieve the `otherToken` after swapping?**

No. The `otherToken` you provide is burned during the swap process and cannot be retrieved.

### 6. **Can I send Ether to this contract?**

No. The `IONSwap` contract does not accept Ether. Any attempt to send Ether will result in the transaction being reverted.

---

## Security and Best Practices

- **Always Verify Contract Addresses**:
  - Ensure you interact with the correct `IONSwap` and token contract addresses to avoid scams.

- **Manage Approvals Carefully**:
  - Only approve the necessary amount of `otherToken` for swapping.
  - Regularly review and adjust token allowances in your wallet.

- **Stay Informed About the Contract Owner**:
  - Be aware that the contract owner can withdraw `pooledToken` from the contract.
  - Monitor the contract's `pooledToken` balance if planning significant swaps.

- **Understand the Burn Mechanism**:
  - Recognize that your `otherToken` will be burned during the swap.
  - Consider the implications of burning on the `otherToken`'s supply and value.

- **Double-Check Token Decimals**:
  - Incorrectly accounting for token decimals can result in failed transactions or unexpected outcomes.

- **Check Swap Rates and Amounts**:
  - Use the `getAmountOut` function to verify the amount of `pooledToken` you will receive before initiating the swap.

---

## Conclusion

The `IONSwap.sol` contract provides a user-friendly and secure way to swap between two ERC20 tokens at a fixed `1:1` exchange rate, adjusted for token decimals, and incorporates a burn mechanism to balance liquidity. By following the steps outlined in this guide and adhering to best practices, users can seamlessly exchange tokens with confidence.

---

# References

- **Smart Contract Code**: `IONSwap.sol`
- **OpenZeppelin Contracts**: Utilized for security and standardization.

