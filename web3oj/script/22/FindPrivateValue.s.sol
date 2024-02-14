// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/22/FindPrivateValue.sol";

contract FindPrivateValueScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("FIND_PRIVATE_VALUE_INSTANCE");

        FindPrivateValue instance = FindPrivateValue(instanceAddress);

        instance.setValue(0x00000000000000000000000000000000000000000000000000000000000002e0);

        bool same = instance.isSame();

        require(same, "Not same");

        vm.stopBroadcast();
    }
}
