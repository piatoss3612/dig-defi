// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/30/SumOfArray.sol";

contract SumOfArrayScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("SUMOFARRAY_INSTANCE");

        SumOfArrayProblem instance = SumOfArrayProblem(instanceAddress);

        SumOfArray solver = new SumOfArray();

        instance.setSumOfArrayContract(address(solver));
       
        vm.stopBroadcast();
    }
}
