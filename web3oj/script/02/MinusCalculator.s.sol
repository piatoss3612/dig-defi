// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/02/MinusCalculator.sol";

contract MinusCalculatorScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("MINUSCALCULATOR_INSTANCE");

        MinusCalculatorProblem problem = MinusCalculatorProblem(
            instanceAddress
        );

        MyMinusCalculator calculator = new MyMinusCalculator();

        problem.setMinusCalculator(address(calculator));

        vm.stopBroadcast();
    }
}
