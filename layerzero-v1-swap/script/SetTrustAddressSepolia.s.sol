// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/CrossChainHelloWorld.sol";

contract SetTrustAddressSepoliaScript is Script {
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
