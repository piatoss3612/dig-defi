// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

// 오버플로우 방지를 위한 라이브러리 (solidity 0.8.0 이상에서는 오버플로우 체크가 기본으로 포함되어 있음)
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}
