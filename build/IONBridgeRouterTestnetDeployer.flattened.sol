// Sources flattened with hardhat v2.22.16 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File @openzeppelin/contracts/utils/Context.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/interfaces/IERC165.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/interfaces/IERC20.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;


// File @openzeppelin/contracts/interfaces/IERC1363.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;


/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File @openzeppelin/contracts/utils/Errors.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}


// File @openzeppelin/contracts/utils/Address.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {Errors.FailedCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors.FailedCall();
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}


// File @openzeppelin/contracts/utils/ReentrancyGuard.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


// File contracts/ion-bridge-router/IIONBridge.sol

// Original license: SPDX_License_Identifier: UNLICENSED
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


// File contracts/swap/IONSwap.sol

// Original license: SPDX_License_Identifier: UNLICENSED

pragma solidity 0.8.27;





/**
 * @title IONSwap
 * @notice This contract enables users to swap between two ERC20 tokens at a fixed exchange rate.
 * It supports both forward swaps (from `otherToken` to `pooledToken`) and reverse swaps (from `pooledToken` back to `otherToken`).
 * The exchange considers the different decimals each token might have, ensuring a fair 1:1 exchange adjusted for decimals.
 *
 * Forward Swap:
 * - Users provide `otherToken` and receive `pooledToken`.
 * - The `otherToken` is accumulated in the contract to provide liquidity for reverse swaps.
 *
 * Reverse Swap:
 * - Users provide `pooledToken` and receive `otherToken`.
 * - The `pooledToken` is accumulated in the contract to provide liquidity for forward swaps.
 *
 * The contract owner can withdraw tokens from the contract, allowing for liquidity management and optimal utilization of assets.
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

    /**
     * @notice Emitted when a forward token swap is performed.
     * @param sender The address initiating the swap.
     * @param amountOtherTokenIn The amount of `otherToken` provided by the sender.
     * @param amountPooledTokenOut The amount of `pooledToken` received by the sender.
     */
    event OnSwap(address indexed sender, uint256 amountOtherTokenIn, uint256 amountPooledTokenOut);

    /**
     * @notice Emitted when a reverse token swap is performed.
     * @param sender The address initiating the swap-back.
     * @param amountPooledTokenIn The amount of `pooledToken` provided by the sender.
     * @param amountOtherTokenOut The amount of `otherToken` received by the sender.
     */
    event OnSwapBack(address indexed sender, uint256 amountPooledTokenIn, uint256 amountOtherTokenOut);

    /**
     * @notice Emitted when tokens are withdrawn from the contract.
     * @param token The address of the token withdrawn.
     * @param receiver The address receiving the withdrawn tokens.
     * @param amount The amount of tokens withdrawn.
     */
    event TokensWithdrawn(IERC20 indexed token, address indexed receiver, uint256 amount);

    /// @notice Thrown when provided pooled token address is the zero address.
    error InvalidPooledTokenAddress(address invalidAddress);

    /// @notice Thrown when provided other token address is the zero address.
    error InvalidOtherTokenAddress(address invalidAddress);

    /// @notice Thrown when both tokens provided are the same.
    error TokensMustBeDifferent(address pooledToken, address otherToken);

    /// @notice Thrown when the swap amount provided is zero.
    error SwapAmountZero();

    /// @notice Thrown when the calculated output amount is zero.
    error OutputAmountZero();

    /// @notice Thrown when the contract's `pooledToken` balance is insufficient for a forward swap.
    error InsufficientPooledTokenBalance();

    /// @notice Thrown when the contract's `otherToken` balance is insufficient for a reverse swap.
    error InsufficientOtherTokenBalance();

    /// @notice Thrown when the zero amount is withdrawn.
    error WithdrawAmountZero();

    /// @notice Thrown when the contract's token balance is insufficient for withdrawal.
    error InsufficientTokenBalance();

    /// @notice Thrown when the receiver address is the zero address.
    error InvalidReceiverAddress();

    /// @notice Thrown when Ether is sent to the contract.
    error EtherNotAccepted();

    /**
     * @notice Initializes the contract with the specified tokens and exchange rates.
     * @param _owner The address to be assigned as the owner of this contract (e.g. an organization's multi-sig address).
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

    /**
     * @notice Swaps a specific amount of `otherToken` for `pooledToken` based on the exchange rate.
     * This is the forward swap: `otherToken` -> `pooledToken`.
     * @param _amount The amount of `otherToken` to swap.
     */
    function swapTokens(uint256 _amount) external nonReentrant {

        if (_amount == 0) {
            revert SwapAmountZero();
        }

        uint256 pooledAmountOut = getPooledAmountOut(_amount);
        if (pooledAmountOut == 0) {
            revert OutputAmountZero();
        }

        if (pooledToken.balanceOf(address(this)) < pooledAmountOut) {
            revert InsufficientPooledTokenBalance();
        }

        // Transfer the `otherToken` from the sender to the contract.
        SafeERC20.safeTransferFrom(otherToken, msg.sender, address(this), _amount);

        // Transfer the equivalent amount of `pooledToken` to the caller.
        SafeERC20.safeTransfer(pooledToken, msg.sender, pooledAmountOut);

        emit OnSwap(msg.sender, _amount, pooledAmountOut);
    }

    /**
     * @notice Swaps a specific amount of `pooledToken` back to `otherToken` based on the exchange rate.
     * This is the reverse swap: `pooledToken` -> `otherToken`.
     * @param _amount The amount of `pooledToken` to swap back.
     */
    function swapTokensBack(uint256 _amount) external nonReentrant {

        if (_amount == 0) {
            revert SwapAmountZero();
        }

        uint256 otherAmountOut = getOtherAmountOut(_amount);
        if (otherAmountOut == 0) {
            revert OutputAmountZero();
        }

        if (otherToken.balanceOf(address(this)) < otherAmountOut) {
            revert InsufficientOtherTokenBalance();
        }

        // Transfer the `pooledToken` from the sender to the contract.
        SafeERC20.safeTransferFrom(pooledToken, msg.sender, address(this), _amount);

        // Transfer the equivalent amount of `otherToken` to the user.
        SafeERC20.safeTransfer(otherToken, msg.sender, otherAmountOut);

        emit OnSwapBack(msg.sender, _amount, otherAmountOut);
    }

    /**
     * @notice Calculates the amount of `pooledToken` that will be received for a given amount of `otherToken`.
     * Used in forward swaps.
     * @param _amount The amount of `otherToken`.
     * @return amountOut The corresponding amount of `pooledToken`.
     */
    function getPooledAmountOut(uint256 _amount) public view returns (uint256 amountOut) {
        amountOut = (_amount * pooledTokenRate) / otherTokenRate;
    }

    /**
     * @notice Calculates the amount of `otherToken` that will be received for a given amount of `pooledToken`.
     * Used in reverse swaps.
     * @param _amount The amount of `pooledToken`.
     * @return amountOut The corresponding amount of `otherToken`.
     */
    function getOtherAmountOut(uint256 _amount) public view returns (uint256 amountOut) {
        amountOut = (_amount * otherTokenRate) / pooledTokenRate;
    }

    /**
     * @notice Withdraws a specified amount of a token to a receiver address.
     * @dev
     *  - Only the ION Network owners add liquidity to this contract; regular users do not deposit liquidity here.
     *  - Thus, calling `withdrawLiquidity` cannot affect user funds.
     *  - Furthermore, this function is restricted to the contract owner, which is managed by the ION Network
     *    organization's multi-sig wallet, ensuring no single centralized entity controls withdrawals.
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

    /**
     * @notice Returns the encoded call data for withdrawing liquidity, to be used in multi-sig transactions.
     * @param _token The ERC20 token to withdraw.
     * @param _receiver The address that will receive the tokens.
     * @param _amount The amount of tokens to withdraw.
     * @return The encoded call data for the withdrawLiquidity function.
     */
    function withdrawLiquidityGetData(
        IERC20 _token,
        address _receiver,
        uint256 _amount
    ) external pure returns (bytes memory) {
        return abi.encodeWithSelector(
            IONSwap.withdrawLiquidity.selector,
            _token,
            _receiver,
            _amount
        );
    }

    /**
     * @notice Rejects any Ether sent directly to the contract.
     * @dev This function is called when Ether is sent to the contract without any data.
     */
    receive() external payable {
        revert EtherNotAccepted();
    }

    /**
     * @notice Rejects any transaction that doesn't match a valid function signature.
     * @dev This function is called for all messages sent to this contract except plain Ether transfers
     *      (i.e., transactions with no data AND with no function specified are rejected).
     */
    fallback() external payable {
        revert EtherNotAccepted();
    }
}


// File contracts/ion-bridge-router/IONBridgeRouter.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.27;





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


// File contracts/ion-bridge-router/IONBridgeRouterTestnetDeployer.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.27;




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
