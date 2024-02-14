// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/27/ErrorHandle.sol";

contract ErrorHandleScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERRORHANDLE_INSTANCE");

        ErrorHandleProblem instance = ErrorHandleProblem(instanceAddress);

        ErrorHandle solver = new ErrorHandle();

        solver.errorHandle(instanceAddress);

        console.log("Error message:", instance.errorMessage());

        vm.stopBroadcast();
    }
}
