// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    bytes32 public constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    bytes32 private immutable _merkleRoot;
    IERC20 private immutable _airdropToken;

    mapping(address claimer => bool claimed) private _hasClaimed;

    event Claimed(address indexed account, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("Merkle Airdrop", "1.0.0") {
        _merkleRoot = merkleRoot;
        _airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata proof, bytes memory signature) external {
        // Prevent the same account from claiming multiple times.
        if (_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // Verify the signature.
        bytes32 digest = getMessageHash(account, amount);
        if (!_isValidSignature(account, digest, signature)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // Hash the input twice to avoid collision attacks.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        // Verify the merkle proof.
        if (!MerkleProof.verify(proof, _merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        // Mark the account as claimed.
        _hasClaimed[account] = true;

        emit Claimed(account, amount);

        // Transfer the airdrop tokens to the recipient.
        _airdropToken.safeTransfer(account, amount);
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    function getMerkleRoot() external view returns (bytes32) {
        return _merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return _airdropToken;
    }

    function hasClaimed(address account) external view returns (bool) {
        return _hasClaimed[account];
    }

    function _isValidSignature(address signer, bytes32 digest, bytes memory signature) internal view returns (bool) {
        return SignatureChecker.isValidSignatureNow(signer, digest, signature);
    }
}
