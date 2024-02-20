// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/CrossChainHelloWorld.sol";

contract DeployScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        new CrossChainHelloWorld(0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1);

        vm.stopBroadcast();
    }
}

contract SetupScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        CrossChainHelloWorld instance = CrossChainHelloWorld(
            0xe9b53942eadEeE83EB998554C042955B248bb30A
        );

        instance.trustAddress(0x1e5501bf7a4821bE9251Aa617560c03f481A39bd);

        vm.stopBroadcast();
    }
}

contract EstimateGasScript is Script {
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

        console.log("Estimated Gas: ", estimatedGas);

        vm.stopBroadcast();
    }
}

contract SendMessageScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        CrossChainHelloWorld instance = CrossChainHelloWorld(
            0xe9b53942eadEeE83EB998554C042955B248bb30A
        );

        (uint estimatedGas, ) = instance.estimateFees(
            10109,
            bytes(""),
            "Hello World from Sepolia V2"
        );

        instance.send{value: estimatedGas}("Hello World from Sepolia V2");

        vm.stopBroadcast();
    }
}
