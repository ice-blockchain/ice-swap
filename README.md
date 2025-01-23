# `Ice Open Network` Bridge-Swap Contracts

The **Bridge-Swap Contracts** project enables seamless swapping and bridging of `ICE v1` and `ICE v2` tokens across BSC and ION networks. It provides users with straightforward contracts to handle token swaps and cross-chain transfers efficiently.

---

# Short description

The **Bridge-Swap Contracts** provide an efficient way to swap between `ICE v1` and `ICE v2` tokens and bridge them across networks. The main components are:

- **IONSwap**: Handles `ICE v1` - `ICE v2` token swaps at fixed exchange rates in the Binance Smart Chain network.
- **IONBridgeRouter**: Simplifies swapping and bridging by acting as a facade for `IONSwap` and `Bridge`.
- **Bridge**: Handles `ICE v2 BSC` - `ICE v2 ION` cross-chain swaps.

## Main Components

- **IONSwap**: A smart contract that facilitates swapping between `ICE v1` and `ICE v2` tokens at a fixed exchange rate (`1:1`), adjusted for their decimals. Users can perform forward swaps (`ICE v1` to `ICE v2`) and reverse swaps (`ICE v2` to `ICE v1`).

  *See [IONSwap Documentation](documentation/IONSwap.md) for detailed information.*

- **IONBridgeRouter**: Acts as a unified interface, combining the functionalities of `IONSwap` and `Bridge` contracts. It simplifies cross-chain token transfers by providing a single point of interaction for swapping and bridging tokens.

  *See [IONBridgeRouter Documentation](documentation/IONBridgeRouter.md) for more details.*

- **Bridge**: Bridges tokens from-to Binance-ION blockchain networks.

  *It is based on the original TON community Bridge contract (forked) and does not have any modifications: https://github.com/ice-blockchain/bridge-solidity. It is in this project for testing purposes.*

- **ICEToken**: The original `ICE v1` token. 

  *The previous version is in this project for unit-testing purposes. The old deployed version is used without modifications. Audit available at: https://skynet.certik.com/projects/ice-open-network#code-security*

## Purpose

The project aims to streamline the process of swapping and bridging tokens, allowing users to exchange tokens between different versions and networks without dealing with complex transactions.

---

# Shortcuts to Source Code

- [IONSwap.sol](./contracts/swap/IONSwap.sol)
- [IONBridgeRouter.sol](./contracts/ion-bridge-router/IONBridgeRouter.sol)

# Shortcuts to Flattened Contracts

- [IONSwap Flattened](./build/IONSwap.flattened.sol)
- [IONBridgeRouterMainnetDeployer Flattened](./build/IONBridgeRouterMainnetDeployer.flattened.sol)
- [IONBridgeRouterTestnetDeployer Flattened](./build/IONBridgeRouterTestnetDeployer.flattened.sol)

---

# Security Audit Request

## Contracts to be Audited
- [ ] [IONSwap.sol](./contracts/swap/IONSwap.sol)
- [ ] [IIONBridge.sol](./contracts/ion-bridge-router/IIONBridge.sol)
- [ ] [IONBridgeRouter.sol](./contracts/ion-bridge-router/IONBridgeRouter.sol)
- [ ] [IONBridgeRouterMainnetDeployer](./contracts/deploy/IONBridgeRouterMainnetDeployer.sol)

## Contracts to be Skipped During the Audit
- 🚫 [bridge](./contracts/bridge). It is the not-modified TON Community's project, which is used as-is.
- 🚫 [test](./contracts/test). Mock contracts only used in tests.
- 🚫 [token](./contracts/token). The existing ICE token, already audited at: https://skynet.certik.com/projects/ice-open-network#code-security.

## Other Artifacts for the Audit

The unit tests are provided here:
[test](./test)

The smart contracts coverage report is provided here:
[coverage](./documentation/coverage)

