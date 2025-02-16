// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {IONBridgeRouter} from "../ion-bridge-router/IONBridgeRouter.sol";
import {IONSwap} from "../swap/IONSwap.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title ION Bridge Router Testnet Deployer
/// @notice Deploys and connects IONSwap and IONBridgeRouter contracts for testnet
contract IONBridgeRouterMainnetDeployer {
    /// @notice Emitted when IONSwap contract is deployed
    /// @param pooledToken The address of the token to be pooled
    /// @param otherToken The address of the second token in the pair
    event IONSwapDeployed(
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

    /// @notice Address of the bridge token contract
    address constant public bridgeAddress = 0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5; // ICE.io v.2 (Bridge)

    /// @notice Address of the other token in the trading pair
    address constant public otherTokenAddress = 0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874; // ICE.io v.1

    /// @notice Instance of the deployed IONSwap contract
    IONSwap public ionSwap;

    /// @notice Instance of the deployed IONBridgeRouter contract
    IONBridgeRouter public ionBridgeRouter;

    /// @notice Deploys the `IONSwap` and `IONBridgeRouter` contracts and connects them.
    constructor() {
        // Step 1: Deploy the IONSwap contract
        ionSwap = new IONSwap(
            IERC20Metadata(bridgeAddress),
            IERC20Metadata(otherTokenAddress)
        );

        // Log IONSwap constructor arguments
        emit IONSwapDeployed(
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

    /// @notice Returns the pooled token and the other token amounts on the IONSwap contract.
    /// @return otherTokenAmount The amount of other token in the IONSwap contract.
    /// @return pooledTokenAmount The amount of pooled token in the IONSwap contract.
    function liquidity() external view returns (uint256 otherTokenAmount, uint256 pooledTokenAmount) {
        pooledTokenAmount = IERC20(ionSwap.pooledToken()).balanceOf(address(ionSwap));
        otherTokenAmount = IERC20(ionSwap.otherToken()).balanceOf(address(ionSwap));
    }
}
