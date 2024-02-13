// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";

contract RunWithABIScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("RUN_WITH_ABI_INSTANCE");

        (bool ok, ) = instanceAddress.call(
            abi.encodePacked(
                abi.encodePacked(bytes4(0xda17c605)), // function selector
                abi.encode(vm.addr(privateKey)) // argument
            )
        );

        require(ok, "Failed to call funcName");

        vm.stopBroadcast();
    }
}
