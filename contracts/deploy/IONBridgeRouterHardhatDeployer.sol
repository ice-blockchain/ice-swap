// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {IONSwap} from "../swap/IONSwap.sol";
import {ICEToken} from "../token/ICEToken.sol";
import {IONBridgeRouter} from "../ion-bridge-router/IONBridgeRouter.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title ION Bridge Router Deployer
/// @notice Deploys and connects Bridge, ICEToken, IONSwap, and IONBridgeRouter contracts
contract IONBridgeRouterHardhatDeployer {
    /// @notice Emitted when the Bridge contract is deployed
    /// @param bridgeAddress Address of the Bridge contract
    event BridgeDeployed(address indexed bridgeAddress);

    /// @notice Emitted when ICEToken contract is deployed
    /// @param iceTokenAddress Address of the ICEToken contract
    event ICETokenDeployed(address indexed iceTokenAddress);

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
    /// @param bridgeAddress The address of the bridge contract
    /// @param swapAddress The address of the deployed IONSwap contract
    event IONBridgeRouterDeployed(
        address indexed otherToken,
        address indexed bridgeToken,
        address indexed bridgeAddress,
        address swapAddress
    );

    /// @notice Address of the multi-signature wallet used for contract ownership
    address public safeGlobalAddress = 0xae4094223718f34f581485E56C209bfa281290dc;

    address public bridgeAddress;

    /// @notice Address of the ICEToken contract
    ICEToken public iceToken;

    /// @notice Instance of the deployed IONSwap contract
    IONSwap public ionSwap;

    /// @notice Instance of the deployed IONBridgeRouter contract
    IONBridgeRouter public ionBridgeRouter;

    /// @notice Deploys the `Bridge`, `ICEToken`, `IONSwap`, and `IONBridgeRouter` contracts and connects them.
    /// @param _bridgeAddress The address of the Bridge contract, which should be roted as the pooled token in the swap.
    constructor(address _bridgeAddress) {

        bridgeAddress = _bridgeAddress;

        // Step 1: Deploy the ICEToken contract as the otherToken
        iceToken = new ICEToken();
        emit ICETokenDeployed(address(iceToken));

        // Step 3: Deploy the IONSwap contract
        ionSwap = new IONSwap(
            address(safeGlobalAddress),
            IERC20Metadata(bridgeAddress),
            IERC20Metadata(address(iceToken))
        );
        emit IONSwapDeployed(
            address(safeGlobalAddress),
            address(bridgeAddress),
            address(iceToken)
        );

        // Step 4: Deploy the IONBridgeRouter contract
        ionBridgeRouter = new IONBridgeRouter(
            address(iceToken),
            address(bridgeAddress),
            address(bridgeAddress),
            address(ionSwap)
        );
        emit IONBridgeRouterDeployed(
            address(iceToken),
            address(bridgeAddress),
            address(bridgeAddress),
            address(ionSwap)
        );

        // The IONSwap's owner is already set to safeGlobalAddress in constructor
    }

    /// @notice Returns the address of the deployed ICEToken contract.
    /// @return Address of the ICEToken contract.
    function getICEToken() external view returns (address) {
        return address(iceToken);
    }

    /// @notice Returns the address of the deployed Bridge contract.
    /// @return Address of the Bridge contract.
    function getBridge() external view returns (address) {
        return address(bridgeAddress);
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
}
