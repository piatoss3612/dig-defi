// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/CrossChainHelloWorld.sol";

contract CrossChainHelloWorldSepoliaScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        new CrossChainHelloWorld(0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1);

        vm.stopBroadcast();
    }
}
