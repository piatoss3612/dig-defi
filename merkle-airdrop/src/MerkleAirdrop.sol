// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    bytes32 private immutable _merkleRoot;
    IERC20 private immutable _airdropToken;

    mapping(address claimer => bool claimed) private _hasClaimed;

    event Claimed(address indexed account, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        _merkleRoot = merkleRoot;
        _airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata proof) external {
        // Prevent the same account from claiming multiple times.
        if (_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
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

    function getMerkleRoot() external view returns (bytes32) {
        return _merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return _airdropToken;
    }

    function hasClaimed(address account) external view returns (bool) {
        return _hasClaimed[account];
    }
}
