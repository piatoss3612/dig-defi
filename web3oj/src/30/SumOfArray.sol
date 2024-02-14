// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISumOfArray {
    function sum(uint[] memory _a) external pure returns (uint);
}

contract SumOfArrayProblem {
    ISumOfArray public sumOfArrayContract;

    function setSumOfArrayContract(address _sumOfArrayContract) public {
        sumOfArrayContract = ISumOfArray(_sumOfArrayContract);
    }
}

contract SumOfArray is ISumOfArray {
    function sum(uint[] memory _a) public pure override returns (uint total) {
        for (uint i = 0; i < _a.length;) {
            unchecked {
                total += _a[i++];
            }
        }
    }
}