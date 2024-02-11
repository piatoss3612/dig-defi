// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {CrosschainNft} from "../src/CrosschainNft.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        CrosschainNft instance = new CrosschainNft(
            0x2d1889fe5B092CD988972261434F7E5f26041115
        );

        console.log("Deployed CrosschainNft at: ", address(instance));

        vm.stopBroadcast();
    }
}

contract CheckNFT is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        CrosschainNft instance = CrosschainNft(
            0x3716B00671B801f34bB4c99Aba5889A13d65c42E
        );

        address owner = instance.ownerOf(1);

        console.log("NFT Owner: ", owner);

        string memory uri = instance.tokenURI(1);

        console.log("NFT URI: ", uri);

        vm.stopBroadcast();
    }
}
