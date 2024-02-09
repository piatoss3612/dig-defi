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

contract CheckURI is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        CrosschainNft instance = CrosschainNft(
            0x4a1A6865A5bb6C9ed988052e6f004c81c9D424Eb
        );

        string memory uri = instance.tokenURI(0);

        console.log("NFT URI: ", uri);

        vm.stopBroadcast();
    }
}
