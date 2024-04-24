// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "./ReentrancyGuard.sol";
import {TransientReentrancyGuard, BrokenTransientReentrancyGuard} from "./TransientReentrancyGuard.sol";

// ReentrancyGuard를 사용하지 않은 버전
contract CounterV0 {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}

// ReentrancyGuard를 사용한 버전
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

contract CounterV3 is BrokenTransientReentrancyGuard {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public noReentrant {
        number++;
    }
}
