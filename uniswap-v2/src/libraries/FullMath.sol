// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.19;

import "./BitMath.sol";

// taken from https://medium.com/coinmonks/math-in-solidity-part-3-percents-and-proportions-4db014e080b1
// license is CC-BY-4.0
library FullMath {
    function fullMul(uint x, uint y) public pure returns (uint l, uint h) {
        uint modulo = type(uint256).max;

        assembly {
            let mm := mulmod(x, y, modulo)
            l := mul(x, y)
            h := sub(mm, l)
            if lt(mm, l) {
                h := sub(h, 1)
            }
        }
    }

    function fullDiv(uint l, uint h, uint z) public pure returns (uint r) {
        require(h < z);
        uint zShift = BitMath.mostSignificantBit(z);
        uint shiftedZ = z;
        if (zShift <= 127) zShift = 0;
        else {
            zShift -= 127;
            shiftedZ = ((shiftedZ - 1) >> zShift) + 1;
        }
        while (h > 0) {
            uint lShift = BitMath.mostSignificantBit(h) + 1;
            uint hShift = 256 - lShift;
            uint e = ((h << hShift) + (l >> lShift)) / shiftedZ;
            if (lShift > zShift) e <<= (lShift - zShift);
            else e >>= (zShift - lShift);
            r += e;
            (uint tl, uint th) = fullMul(e, z);
            h -= th;
            if (tl > l) h -= 1;
            l -= tl;
        }
        r += l / z;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        require(h < d, "FullMath: FULLDIV_OVERFLOW");
        return fullDiv(l, h, d);
    }
}
