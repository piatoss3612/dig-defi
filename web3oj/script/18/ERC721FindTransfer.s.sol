// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/18/ERC721FindTransfer.sol";

contract ERC721FindTransferScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC721FINDTRANSFER_INSTANCE");

        Web3OnlineJudgeNFTFind instance = Web3OnlineJudgeNFTFind(instanceAddress);

        uint256 tokenId = 0x2f0; // owned by player

        address owner = instance.ownerOf(tokenId);

        console.log("old owner", owner);

        instance.approve(instanceAddress, tokenId);
        instance.transferFrom(owner, instanceAddress, tokenId);

        owner = instance.ownerOf(tokenId);

        console.log("new owner", owner);

        vm.stopBroadcast();
    }
}
