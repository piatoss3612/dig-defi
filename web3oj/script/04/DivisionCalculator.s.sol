// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/04/DivisionCalculator.sol";

contract DivisionCalculatorScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("DIVISIONCALCULATOR_INSTANCE");

        DivisionCalculatorProblem problem = DivisionCalculatorProblem(
            instanceAddress
        );

        MyDivisionCalculator calculator = new MyDivisionCalculator();

        problem.setDivisionCalculator(address(calculator));

        vm.stopBroadcast();
    }
}
