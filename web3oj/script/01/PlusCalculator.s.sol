// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/01/PlusCalculator.sol";

contract PlusCalculatorScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("PLUSCALCULATOR_INSTANCE");

        PlusCalculatorProblem problem = PlusCalculatorProblem(instanceAddress);

        MyPlusCalculator calculator = new MyPlusCalculator();

        problem.setPlusCalculator(address(calculator));

        vm.stopBroadcast();
    }
}
