# Manual for Deploying `IONBridgeRouterTestnetDeployer` and Adding Liquidity to Enable Swapping

## Introduction

This manual provides step-by-step instructions on how to deploy the `IONBridgeRouterTestnetDeployer` smart contract and add liquidity to the `IONSwap` contract, enabling token swapping functionality. This guide is tailored for deployment in a testnet environment.

## Prerequisites

Before you begin, ensure you have the following:

- **Development Environment:**
    - Node.js and npm installed.
    - Hardhat installed:
      ```bash
      npm install --save-dev hardhat
      ```
    - A code editor (e.g., Visual Studio Code).

- **Blockchain Network:**
    - Access to a testnet (e.g., Binance Smart Chain (BSC) Testnet).
    - Testnet cryptocurrency (e.g., Test BNB) for gas fees in your deployer wallet.

- **Wallets and Addresses:**
    - Your deployer wallet's private key (ensure it is kept secure).
    - Access to the multi-signature wallet used as the contract owner (`safeGlobalAddress`), or modify the contract to use an address you control for testing purposes.

- **Token Contracts:**
    - Testnet addresses for `bridgeAddress` and `otherTokenAddress`, or deploy mock ERC20 tokens for testing.

- **Contracts Code:**
    - The Solidity source code files for all contracts involved:
        - `IONBridgeRouterTestnetDeployer.sol`
        - `IONSwap.sol`
        - `IONBridgeRouter.sol`
        - Any dependencies and interfaces.

## Steps

### 1. Project Setup

#### a. Initialize a New Hardhat Project

```bash
mkdir ion-swap-project
cd ion-swap-project
npm init -y
npm install --save-dev hardhat
npx hardhat
```

Select "Create an empty hardhat.config.js".

#### b. Install Dependencies

```bash
npm install --save-dev @nomiclabs/hardhat-ethers ethers @openzeppelin/contracts
```

### 2. Configure Hardhat

Create or modify the `hardhat.config.js` file to include your network settings:

```javascript
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.27",
  networks: {
    bscTestnet: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      chainId: 97,
      accounts: ['<YOUR_PRIVATE_KEY>'], // Replace with your deployer wallet's private key
    },
  },
};
```

### 3. Add Contract Source Files

Place the following contract files in the `contracts` directory:

- `contracts/ion-bridge-router/IONBridgeRouterTestnetDeployer.sol`
- `contracts/swap/IONSwap.sol`
- `contracts/ion-bridge-router/IONBridgeRouter.sol`
- Any other dependencies or contracts provided.

### 4. Modify Contract Addresses (If Necessary)

If you do not have the actual testnet addresses for `safeGlobalAddress`, `bridgeAddress`, and `otherTokenAddress`, you can deploy mock tokens and use their addresses.

#### a. Deploy Mock Tokens

Create a `ERC20Mock.sol` in `contracts/test`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, 1000000 * (10 ** decimals_));
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
```

Deploy two instances of `ERC20Mock`:

- **Bridge Token Mock** (`bridgeAddress`):
    - Name: "Bridge Token"
    - Symbol: "BRIDGE"
    - Decimals: 18

- **Other Token Mock** (`otherTokenAddress`):
    - Name: "Other Token"
    - Symbol: "OTHER"
    - Decimals: 18

Compile and deploy these mock tokens to the testnet.

#### b. Update Contract Addresses

In `IONBridgeRouterTestnetDeployer.sol`, update:

- `safeGlobalAddress`: Use an address you control for testing.
- `bridgeAddress`: The address of the Bridge Token Mock deployed.
- `otherTokenAddress`: The address of the Other Token Mock deployed.

### 5. Compile Contracts

Compile your contracts to ensure there are no errors.

```bash
npx hardhat compile
```

### 6. Deploy Contracts

#### a. Create a Deployment Script

Create `scripts/deploy.js`:

```javascript
const hre = require("hardhat");

async function main() {
  // Deploy IONBridgeRouterTestnetDeployer
  const Deployer = await hre.ethers.getContractFactory("IONBridgeRouterTestnetDeployer");
  const deployer = await Deployer.deploy();

  await deployer.deployed();

  console.log("IONBridgeRouterTestnetDeployer deployed to:", deployer.address);

  // Retrieve deployed contract addresses
  const ionSwapAddress = await deployer.getIONSwap();
  const ionBridgeRouterAddress = await deployer.getIONBridgeRouter();

  console.log("IONSwap deployed to:", ionSwapAddress);
  console.log("IONBridgeRouter deployed to:", ionBridgeRouterAddress);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
```

#### b. Deploy to Testnet

Deploy the contracts to BSC Testnet:

```bash
npx hardhat run scripts/deploy.js --network bscTestnet
```

#### c. Record Deployed Addresses

Note down the addresses of:

- `IONBridgeRouterTestnetDeployer`
- `IONSwap`
- `IONBridgeRouter`

### 7. Add Liquidity to Enable Swapping

Liquidity must be added to the `IONSwap` contract by transferring tokens to it.

#### a. Mint Tokens

Ensure your deployer wallet has sufficient tokens.

```javascript
const [deployer] = await ethers.getSigners();

const ERC20Mock = await ethers.getContractFactory("ERC20Mock");
const bridgeToken = await ERC20Mock.attach('<BRIDGE_TOKEN_ADDRESS>');
const otherToken = await ERC20Mock.attach('<OTHER_TOKEN_ADDRESS>');

// Mint tokens to deployer
await bridgeToken.mint(deployer.address, ethers.utils.parseEther("1000000"));
await otherToken.mint(deployer.address, ethers.utils.parseEther("1000000"));
```

#### b. Approve Token Transfer

Before transferring tokens to `IONSwap`, approve the transfer.

```javascript
const ionswapAddress = '<IONSwap_ADDRESS>';

// Approve bridgeToken transfer
await bridgeToken.approve(ionswapAddress, ethers.utils.parseEther("500000"));

// Approve otherToken transfer
await otherToken.approve(ionswapAddress, ethers.utils.parseEther("500000"));
```

#### c. Transfer Tokens to `IONSwap` Contract

Transfer the tokens to the `IONSwap` contract to provide liquidity.

```javascript
// Transfer bridge tokens
await bridgeToken.transfer(ionswapAddress, ethers.utils.parseEther("500000"));

// Transfer other tokens
await otherToken.transfer(ionswapAddress, ethers.utils.parseEther("500000"));
```

#### d. Verify Balances

Check that the `IONSwap` contract now holds the tokens.

```javascript
const bridgeTokenBalance = await bridgeToken.balanceOf(ionswapAddress);
const otherTokenBalance = await otherToken.balanceOf(ionswapAddress);

console.log("IONSwap BridgeToken Balance:", ethers.utils.formatEther(bridgeTokenBalance));
console.log("IONSwap OtherToken Balance:", ethers.utils.formatEther(otherTokenBalance));
```

### 8. Test Swapping Functionality

#### a. Simulate a User Swapping Tokens

Use a different wallet to simulate a user.

```javascript
const user = ethers.Wallet.createRandom().connect(ethers.provider);

// Fund the user with test BNB
// This can be done via the testnet faucet or by transferring from deployer

// Mint tokens to the user
await bridgeToken.mint(user.address, ethers.utils.parseEther("1000"));
await otherToken.mint(user.address, ethers.utils.parseEther("1000"));

// User approves `IONSwap`
await otherToken.connect(user).approve(ionswapAddress, ethers.utils.parseEther("500"));

// User calls `swapTokens` to swap OtherToken for BridgeToken
const ionswap = await ethers.getContractAt("IONSwap", ionswapAddress);

// Swap 500 OtherToken for BridgeToken
await ionswap.connect(user).swapTokens(ethers.utils.parseEther("500"));
```

#### b. Check User's Token Balances

```javascript
const userBridgeBalance = await bridgeToken.balanceOf(user.address);
const userOtherBalance = await otherToken.balanceOf(user.address);

console.log("User BridgeToken Balance:", ethers.utils.formatEther(userBridgeBalance));
console.log("User OtherToken Balance:", ethers.utils.formatEther(userOtherBalance));
```

#### c. Verify Swapping Back

```javascript
// User approves `IONSwap` to spend BridgeToken
await bridgeToken.connect(user).approve(ionswapAddress, ethers.utils.parseEther("200"));

// Swap BridgeToken back to OtherToken
await ionswap.connect(user).swapTokensBack(ethers.utils.parseEther("200"));

// Check balances again
const updatedUserBridgeBalance = await bridgeToken.balanceOf(user.address);
const updatedUserOtherBalance = await otherToken.balanceOf(user.address);

console.log("Updated User BridgeToken Balance:", ethers.utils.formatEther(updatedUserBridgeBalance));
console.log("Updated User OtherToken Balance:", ethers.utils.formatEther(updatedUserOtherBalance));
```

### 9. Additional Considerations

#### a. Ownership and Access Control

In the testnet environment, you may not have access to the `safeGlobalAddress`. For testing purposes, you can:

- Modify the `IONBridgeRouterTestnetDeployer.sol` contract to use your address as the `safeGlobalAddress`.
- Ensure any owner-only functions are called by the correct address.

#### b. Dealing with Approvals

Ensure that any token transfers are properly approved. If you encounter `ERC20: transfer amount exceeds allowance`, double-check the approvals.

#### c. Using Block Explorers

Use testnet block explorers (e.g., [BscScan Testnet](https://testnet.bscscan.com/)) to verify transactions and contract addresses.

### 10. Cleaning Up

After testing, you may want to:

- Revoke approvals to the `IONSwap` contract.
- Transfer any remaining tokens back to your wallet or burn them.
- Reset your test environment as needed.

## Conclusion

You have successfully deployed the `IONBridgeRouterTestnetDeployer` smart contract and added liquidity to the `IONSwap` contract. This setup allows for token swapping between the specified tokens in a testnet environment, enabling you to test and verify the smart contract functionality.

Remember to follow best practices and security measures when deploying and interacting with smart contracts, even in a testnet environment.

