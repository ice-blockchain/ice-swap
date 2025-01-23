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
