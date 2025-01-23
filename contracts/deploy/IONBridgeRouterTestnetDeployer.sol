// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {IONSwap} from "../swap/IONSwap.sol";
import {IONBridgeRouter} from "../ion-bridge-router/IONBridgeRouter.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title ION Bridge Router Testnet Deployer
/// @notice Deploys and connects IONSwap and IONBridgeRouter contracts for testnet
contract IONBridgeRouterTestnetDeployer {
    /// @notice Emitted when IONSwap contract is deployed
    /// @param owner The address of the contract owner (multi-sig wallet)
    /// @param pooledToken The address of the token to be pooled
    /// @param otherToken The address of the second token in the pair
    event IONSwapDeployed(
        address indexed owner,
        address indexed pooledToken,
        address indexed otherToken
    );

    /// @notice Emitted when IONBridgeRouter contract is deployed
    /// @param otherToken The address of the second token in the pair
    /// @param bridgeToken The address of the bridge token
    /// @param pooledToken The address of the token to be pooled
    /// @param swapAddress The address of the deployed IONSwap contract
    event IONBridgeRouterDeployed(
        address indexed otherToken,
        address indexed bridgeToken,
        address indexed pooledToken,
        address swapAddress
    );

    /// @notice Address of the multi-signature wallet used for contract ownership
    address constant public safeGlobalAddress = 0xae4094223718f34f581485E56C209bfa281290dc;

    /// @notice Address of the bridge token contract
    address constant public bridgeAddress = 0xC632928ab4fC995e04b4D66da62C28cE56e2bd73;

    /// @notice Address of the other token in the trading pair
    address constant public otherTokenAddress = 0x2A0864a15a63AC237a46405CCd6aD7Fa0513050D;

    /// @notice Instance of the deployed IONSwap contract
    IONSwap public ionSwap;

    /// @notice Instance of the deployed IONBridgeRouter contract
    IONBridgeRouter public ionBridgeRouter;

    /// @notice Deploys the `IONSwap` and `IONBridgeRouter` contracts and connects them.
    constructor() {
        // Step 1: Deploy the IONSwap contract
        ionSwap = new IONSwap(
            address(safeGlobalAddress),
            IERC20Metadata(bridgeAddress),
            IERC20Metadata(otherTokenAddress)
        );

        // Log IONSwap constructor arguments
        emit IONSwapDeployed(
            address(safeGlobalAddress),
            bridgeAddress,
            otherTokenAddress
        );

        // Step 2: Deploy the IONBridgeRouter contract
        ionBridgeRouter = new IONBridgeRouter(
            otherTokenAddress,
            bridgeAddress,
            bridgeAddress,
            address(ionSwap)
        );

        // Log IONBridgeRouter constructor arguments
        emit IONBridgeRouterDeployed(
            otherTokenAddress,
            bridgeAddress,
            bridgeAddress,
            address(ionSwap)
        );
    }

    /// @notice Returns the address of the aggregated multi-sig wallet.
    /// @return Address of the multi-sig wallet.
    function getMultiSigWallet() pure external returns (address) {
        return address(safeGlobalAddress);
    }

    /// @notice Returns the address of the deployed IONSwap contract.
    /// @return Address of the IONSwap contract.
    function getIONSwap() external view returns (address) {
        return address(ionSwap);
    }

    /// @notice Returns the address of the deployed IONBridgeRouter contract.
    /// @return Address of the IONBridgeRouter contract.
    function getIONBridgeRouter() external view returns (address) {
        return address(ionBridgeRouter);
    }

    /// @notice Returns the address of the bridge token.
    /// @return Address of the bridge token.
    function getIONBridge() external pure returns (address) {
        return bridgeAddress;
    }

    /// @notice Returns the address of the pooled token (same as bridge token in this case).
    /// @return Address of the pooled token.
    function getPooledToken() external pure returns (address) {
        return bridgeAddress;
    }

    /// @notice Returns the address of the other token used in the swap.
    /// @return Address of the other token.
    function getOtherToken() external pure returns (address) {
        return otherTokenAddress;
    }

    /// @notice Returns the pooled token and the other token amounts on the IONSwap contract.
    /// @return otherTokenAmount The amount of other token in the IONSwap contract.
    /// @return pooledTokenAmount The amount of pooled token in the IONSwap contract.
    function liquidity() external view returns (uint256 otherTokenAmount, uint256 pooledTokenAmount) {
        pooledTokenAmount = IERC20(ionSwap.pooledToken()).balanceOf(address(ionSwap));
        otherTokenAmount = IERC20(ionSwap.otherToken()).balanceOf(address(ionSwap));
    }
}
