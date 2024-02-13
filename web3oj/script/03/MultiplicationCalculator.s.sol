// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/03/MultiplicationCalculator.sol";

contract MultiplicationCalculatorScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress(
            "MULTIPLICATIONCALCULATOR_INSTANCE"
        );

        MultiplicationCalculatorProblem problem = MultiplicationCalculatorProblem(
                instanceAddress
            );

        MyMultiplicationCalculator calculator = new MyMultiplicationCalculator();

        problem.setMultiplicationCalculator(address(calculator));

        vm.stopBroadcast();
    }
}
