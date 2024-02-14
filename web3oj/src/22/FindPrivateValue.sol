// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FindPrivateValue {
    uint256 private secret;
    uint256 public value;

    constructor(uint256 _secret) {
        secret = _secret;
    }

    function setValue(uint256 _value) public {
        value = _value;
    }

    function isSame() public view returns (bool) {
        return value == secret;
    }
}