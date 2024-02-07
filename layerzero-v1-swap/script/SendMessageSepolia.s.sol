// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/CrossChainHelloWorld.sol";

contract SendMessageSepoliaScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        CrossChainHelloWorld instance = CrossChainHelloWorld(
            0xe9b53942eadEeE83EB998554C042955B248bb30A
        );

        (uint estimatedGas, ) = instance.estimateFees(
            10109,
            bytes(""),
            "Hello World from Sepolia"
        );

        instance.send{value: estimatedGas}("Hello World from Sepolia");

        vm.stopBroadcast();
    }
}
