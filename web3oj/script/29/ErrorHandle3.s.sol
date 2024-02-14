// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/29/ErrorHandle3.sol";

contract ErrorHandle3Script is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERRORHANDLE3_INSTANCE");

        ErrorHandle solver = new ErrorHandle();

        solver.errorHandle(instanceAddress);
       
        vm.stopBroadcast();
    }
}
