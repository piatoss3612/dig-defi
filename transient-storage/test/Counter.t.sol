// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {CounterV0, CounterV1, CounterV2, CounterV3} from "../src/Counter.sol";

contract CounterTest is Test {
    CounterV0 public v0;
    CounterV1 public v1;
    CounterV2 public v2;
    CounterV3 public v3;

    function setUp() public {
        v0 = new CounterV0();
        v1 = new CounterV1();
        v2 = new CounterV2();
        v3 = new CounterV3();
    }

    function test_IncrementV0() public {
        uint256 ethBefore = gasleft();
        v0.increment();
        uint256 ethAfter = gasleft();
        assertEq(v0.number(), 1);

        console.log("gas used: ", ethBefore - ethAfter);
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

    function test_RevertIncrementV3TwiceByNotClearingTS() public {
        v3.increment();
        assertEq(v3.number(), 1);

        // v3.increment()을 호출하면 v3의 TS가 0으로 초기화되지 않아서 revert된다.
        vm.expectRevert();
        v3.increment();
    }
}
