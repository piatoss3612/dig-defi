// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "./ReentrancyGuard.sol";
import {TransientReentrancyGuard} from "./TransientReentrancyGuard.sol";

contract CounterV1 is ReentrancyGuard {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public noReentrant {
        number++;
    }
}

contract CounterV2 is TransientReentrancyGuard {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public noReentrant {
        number++;
    }
}
