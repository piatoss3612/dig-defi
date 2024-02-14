// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/26/StringCompare.sol";

contract StringCompareScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("STRINGCOMPARE_INSTANCE");

        StringCompareProblem instance = StringCompareProblem(instanceAddress);

        StringCompare solver = new StringCompare();

        instance.setStringCompareContract(address(solver));

        vm.stopBroadcast();
    }
}
