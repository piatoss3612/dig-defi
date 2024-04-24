// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

abstract contract TransientReentrancyGuard {
    bytes32 private constant _GUARD_SLOT = 0x8e94fed44239eb2314ab7a406345e6c5a8f0ccedf3b600de3d004e672c33abf5; // keccak256("ReentrancyGuard")

    modifier noReentrant() {
        assembly {
            if tload(_GUARD_SLOT) { revert(0, 0) }
            tstore(_GUARD_SLOT, 1)
        }
        _;
        // Unlocks the guard, making the pattern composable.
        // After the function exits, it can be called again, even in the same transaction.
        assembly {
            tstore(_GUARD_SLOT, 0)
        }
    }
}

abstract contract BrokenTransientReentrancyGuard {
    bytes32 private constant _GUARD_SLOT = 0x8e94fed44239eb2314ab7a406345e6c5a8f0ccedf3b600de3d004e672c33abf5; // keccak256("ReentrancyGuard")

    modifier noReentrant() {
        assembly {
            if tload(_GUARD_SLOT) { revert(0, 0) }
            tstore(_GUARD_SLOT, 1)
        }
        _;
    }
}
