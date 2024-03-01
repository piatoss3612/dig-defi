// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.19;

import "./BitMath.sol";

// taken from https://medium.com/coinmonks/math-in-solidity-part-3-percents-and-proportions-4db014e080b1
// license is CC-BY-4.0
library FullMath {
    function fullMul(uint256 x, uint256 y) public pure returns (uint256 l, uint256 h) {
        uint256 modulo = type(uint256).max;

        assembly {
            let mm := mulmod(x, y, modulo)
            l := mul(x, y)
            h := sub(mm, l)
            if lt(mm, l) { h := sub(h, 1) }
        }
    }

    function fullDiv(uint256 l, uint256 h, uint256 z) public pure returns (uint256 r) {
        require(h < z);
        uint256 zShift = BitMath.mostSignificantBit(z);
        uint256 shiftedZ = z;
        if (zShift <= 127) {
            zShift = 0;
        } else {
            zShift -= 127;
            shiftedZ = ((shiftedZ - 1) >> zShift) + 1;
        }
        while (h > 0) {
            uint256 lShift = BitMath.mostSignificantBit(h) + 1;
            uint256 hShift = 256 - lShift;
            uint256 e = ((h << hShift) + (l >> lShift)) / shiftedZ;
            if (lShift > zShift) e <<= (lShift - zShift);
            else e >>= (zShift - lShift);
            r += e;
            (uint256 tl, uint256 th) = fullMul(e, z);
            h -= th;
            if (tl > l) h -= 1;
            l -= tl;
        }
        r += l / z;
    }

    function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        require(h < d, "FullMath: FULLDIV_OVERFLOW");
        return fullDiv(l, h, d);
    }
}
