// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    IAccount,
    ACCOUNT_VALIDATION_SUCCESS_MAGIC
} from "@matterlabs/zksync-contracts/l2/system-contracts/interfaces/IAccount.sol";
import {
    Transaction,
    TransactionHelper
} from "@matterlabs/zksync-contracts/l2/system-contracts/libraries/TransactionHelper.sol";
import {INonceHolder} from "@matterlabs/zksync-contracts/l2/system-contracts/interfaces/INonceHolder.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
// Used for signature validation
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
// Access zkSync system contracts for nonce validation via NONCE_HOLDER_SYSTEM_CONTRACT
import {
    BOOTLOADER_FORMAL_ADDRESS,
    NONCE_HOLDER_SYSTEM_CONTRACT,
    DEPLOYER_SYSTEM_CONTRACT
} from "@matterlabs/zksync-contracts/l2/system-contracts/Constants.sol";
// to call non-view function of system contracts
import {
    SystemContractsCaller,
    Utils
} from "@matterlabs/zksync-contracts/l2/system-contracts/libraries/SystemContractsCaller.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AgentAccount is IAccount, IERC1271, Ownable {
    // to get transaction hash
    using TransactionHelper for Transaction;

    bytes4 public constant EIP1271_SUCCESS_RETURN_VALUE = 0x1626ba7e;

    modifier onlyBootloader() {
        require(msg.sender == BOOTLOADER_FORMAL_ADDRESS, "Only bootloader can call this method");
        // Continue execution if called from the bootloader.
        _;
    }

    constructor(address _owner) Ownable(_owner) {}

    function validateTransaction(bytes32, bytes32 _suggestedSignedHash, Transaction calldata _transaction)
        external
        payable
        override
        onlyBootloader
        returns (bytes4 magic)
    {
        magic = _validateTransaction(_suggestedSignedHash, _transaction);
    }

    function _validateTransaction(bytes32 _suggestedSignedHash, Transaction calldata _transaction)
        internal
        returns (bytes4 magic)
    {
        // Incrementing the nonce of the account.
        // Note, that reserved[0] by convention is currently equal to the nonce passed in the transaction
        SystemContractsCaller.systemCallWithPropagatedRevert(
            uint32(gasleft()),
            address(NONCE_HOLDER_SYSTEM_CONTRACT),
            0,
            abi.encodeCall(INonceHolder.incrementMinNonceIfEquals, (_transaction.nonce))
        );

        bytes32 txHash;
        // While the suggested signed hash is usually provided, it is generally
        // not recommended to rely on it to be present, since in the future
        // there may be tx types with no suggested signed hash.
        if (_suggestedSignedHash == bytes32(0)) {
            txHash = _transaction.encodeHash();
        } else {
            txHash = _suggestedSignedHash;
        }

        // The fact there is are enough balance for the account
        // should be checked explicitly to prevent user paying for fee for a
        // transaction that wouldn't be included on Ethereum.
        uint256 totalRequiredBalance = _transaction.totalRequiredBalance();
        require(totalRequiredBalance <= address(this).balance, "Not enough balance for fee + value");

        if (isValidSignature(txHash, _transaction.signature) == EIP1271_SUCCESS_RETURN_VALUE) {
            magic = ACCOUNT_VALIDATION_SUCCESS_MAGIC;
        } else {
            magic = bytes4(0);
        }
    }

    function executeTransaction(bytes32, bytes32, Transaction calldata _transaction)
        external
        payable
        override
        onlyBootloader
    {
        _executeTransaction(_transaction);
    }

    function _executeTransaction(Transaction calldata _transaction) internal {
        address to = address(uint160(_transaction.to));
        uint128 value = Utils.safeCastToU128(_transaction.value);
        bytes memory data = _transaction.data;

        if (to == address(DEPLOYER_SYSTEM_CONTRACT)) {
            uint32 gas = Utils.safeCastToU32(gasleft());

            // Note, that the deployer contract can only be called
            // with a "systemCall" flag.
            SystemContractsCaller.systemCallWithPropagatedRevert(gas, to, value, data);
        } else {
            bool success;
            assembly {
                success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)
            }
            require(success);
        }
    }

    function executeTransactionFromOutside(Transaction calldata _transaction) external payable {
        _validateTransaction(bytes32(0), _transaction);
        _executeTransaction(_transaction);
    }

    function isValidSignature(bytes32 _hash, bytes memory _signature) public view override returns (bytes4 magic) {
        bytes32 hash = MessageHashUtils.toEthSignedMessageHash(_hash);
        address recoveredAddress = ECDSA.recover(hash, _signature);

        magic = EIP1271_SUCCESS_RETURN_VALUE;

        // Note, that we should abstain from using the require here in order to allow for fee estimation to work
        if (recoveredAddress != owner()) {
            magic = bytes4(0);
        }
    }

    function payForTransaction(bytes32, bytes32, Transaction calldata _transaction)
        external
        payable
        override
        onlyBootloader
    {
        bool success = _transaction.payToTheBootloader();
        require(success, "Failed to pay the fee to the operator");
    }

    function prepareForPaymaster(
        bytes32, // _txHash
        bytes32, // _suggestedSignedHash
        Transaction calldata _transaction
    ) external payable override onlyBootloader {
        _transaction.processPaymasterInput();
    }

    fallback() external {
        // fallback of default account shouldn't be called by bootloader under no circumstances
        assert(msg.sender != BOOTLOADER_FORMAL_ADDRESS);

        // If the contract is called directly, behave like an EOA
    }

    receive() external payable {
        // If the contract is called directly, behave like an EOA.
        // Note, that is okay if the bootloader sends funds with no calldata as it may be used for refunds/operator payments
    }
}
