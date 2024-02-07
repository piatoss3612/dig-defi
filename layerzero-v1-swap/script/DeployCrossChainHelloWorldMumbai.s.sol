// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/CrossChainHelloWorld.sol";

contract CrossChainHelloWorldMumbaiScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        new CrossChainHelloWorld(0xf69186dfBa60DdB133E91E9A4B5673624293d8F8);

        vm.stopBroadcast();
    }
}
