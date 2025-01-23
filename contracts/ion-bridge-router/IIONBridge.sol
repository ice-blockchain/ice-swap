// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/// @title IIONBridge Interface
/// @notice Interface for the ION Bridge contract that handles cross-chain token transfers
interface IIONBridge {
    /// @notice Structure representing an address in the ION network
    /// @param workchain The workchain identifier where the address exists
    /// @param address_hash The 32-byte hash of the address
    struct IONAddress {
        int8 workchain;
        bytes32 address_hash;
    }

    /// @notice Structure representing a transaction identifier in the ION network
    /// @param address_ The sender's address in the ION network
    /// @param tx_hash The transaction hash on the ION bridge smart contract
    /// @param lt The logical time of the transaction on the ION bridge smart contract
    struct IONTxID {
        IONAddress address_;
        bytes32 tx_hash;
        uint64 lt;
    }

    /// @notice Structure containing swap operation data
    /// @param receiver The EVM address that will receive the wrapped IONs
    /// @param amount The amount of nano-ions to receive in the EVM network
    /// @param tx The ION transaction identifier data
    struct SwapData {
        address receiver;
        uint64 amount;
        IONTxID tx;
    }

    /// @notice Structure containing oracle signature data
    /// @param signer The EVM address of the oracle
    /// @param signature The cryptographic signature provided by the oracle
    struct Signature {
        address signer;
        bytes signature;
    }

    /// @notice Burns wrapped ION tokens and initiates transfer to ION network
    /// @param amount The amount of tokens to burn
    /// @param addr The destination address in the ION network
    function burn(uint256 amount, IONAddress memory addr) external;

    /// @notice Submits oracle signatures to approve token minting
    /// @param data The swap operation data
    /// @param signatures Array of oracle signatures validating the operation
    function voteForMinting(SwapData memory data, Signature[] memory signatures) external;
}