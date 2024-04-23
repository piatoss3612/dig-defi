// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {CounterV1, CounterV2} from "../src/Counter.sol";

contract CounterTest is Test {
    CounterV1 public v1;
    CounterV2 public v2;

    function setUp() public {
        v1 = new CounterV1();
        v2 = new CounterV2();
    }

    function test_IncrementV1() public {
        uint256 ethBefore = gasleft();
        v1.increment();
        uint256 ethAfter = gasleft();
        assertEq(v1.number(), 1);

        console.log("gas used: ", ethBefore - ethAfter);
    }

    function test_IncrementV2() public {
        uint256 ethBefore = gasleft();
        v2.increment();
        uint256 ethAfter = gasleft();
        assertEq(v2.number(), 1);

        console.log("gas used: ", ethBefore - ethAfter);
    }
}
