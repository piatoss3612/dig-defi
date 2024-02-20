// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

// 112비트 고정소수점 연산을 위한 라이브러리
library UQ112x112 {
    uint224 constant Q112 = 2 ** 112;

    // uint112를 UQ112x112로 인코딩
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows (y의 최댓값은 2^112 - 1이므로 z의 최댓값은 2^224 - 2^112)
    }

    // UQ112x112를 uint112로 나누어 UQ112x112를 반환
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}
