// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

abstract contract ReentrancyGuard {
    bool private _locked;

    modifier noReentrant() {
        if (_locked) {
            revert("ReentrancyGuard: reentrant call");
        }
        _locked = true;
        _;
        _locked = false;
    }
}
