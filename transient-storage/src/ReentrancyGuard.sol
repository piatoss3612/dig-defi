// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

abstract contract ReentrancyGuard {
    bool private _locked;

    modifier noReentrant() {
        assembly {
            if sload(_locked.slot) { revert(0, 0) }
            sstore(_locked.slot, 1)
        }
        _;
        assembly {
            sstore(_locked.slot, 0)
        }
    }
}
