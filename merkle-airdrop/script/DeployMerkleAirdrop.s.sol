// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {LokiToken} from "src/LokiToken.sol";

contract DeployMerkleAirdropScript is Script {
    bytes32 merkleRoot = 0xd83f4a7eed75e3d20922784ea7c1801033b28025f98b7074724e5e7cb17879d6;
    uint256 amountToCollect = 25 * 1e18;
    bytes32 proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proofOne, proofTwo];

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        LokiToken token = new LokiToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(merkleRoot, token);

        token.mint(address(airdrop), amountToCollect * 4);

        bytes32 digest = airdrop.getMessageHash(msg.sender, amountToCollect);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(digest);

        bytes memory signature = abi.encodePacked(r, s, v);

        airdrop.claim(msg.sender, amountToCollect, proof, signature);

        vm.stopBroadcast();
    }
}
