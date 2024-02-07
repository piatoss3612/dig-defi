// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/CrossChainHelloWorld.sol";
import "forge-std/Test.sol";

contract SetTrustAddressMumbaiScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        CrossChainHelloWorld instance = CrossChainHelloWorld(
            0x1e5501bf7a4821bE9251Aa617560c03f481A39bd
        );

        console.log("data: ", instance.data());

        vm.stopBroadcast();
    }
}
