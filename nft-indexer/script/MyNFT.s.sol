//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MyNFT} from "../src/MyNFT.sol";

contract MyNFTScript is Script {
    function run() public {
        vm.startBroadcast();
        MyNFT nft = new MyNFT();

        console.log("Deployed MyNFT at address: ", address(nft));

        nft.testMint();
    }
}
