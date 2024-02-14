// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/28/ErrorHandle2.sol";

contract ErrorHandle2Script is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERRORHANDLE2_INSTANCE");

        ErrorHandleProblem2 instance = ErrorHandleProblem2(instanceAddress);

        ErrorHandle2 solver = new ErrorHandle2();

        solver.errorHandle(instanceAddress);

        console.log("Error code:", instance.errorCode());
       
        vm.stopBroadcast();
    }
}
