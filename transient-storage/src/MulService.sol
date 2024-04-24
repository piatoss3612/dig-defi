// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract MulService {
    function setMultiplier(uint256 multiplier) external {
        assembly {
            tstore(0, multiplier)
        }
    }

    function getMultiplier() private view returns (uint256 multiplier) {
        assembly {
            multiplier := tload(0)
        }
    }

    function multiply(uint256 value) external view returns (uint256) {
        return value * getMultiplier();
    }
}
