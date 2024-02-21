// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../interfaces/IUniswapV2Pair.sol";
import "../libraries/UniswapV2OracleLibrary.sol";
import "../libraries/FixedPoint.sol";

contract SimpleOracle {
    error InvalidPeriod();
    error InvalidToken();

    using FixedPoint for *;

    uint public constant PERIOD = 15 seconds;

    IUniswapV2Pair public immutable pair;
    address public immutable token0;
    address public immutable token1;

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint32 public blockTimestampLast;

    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;

    constructor(IUniswapV2Pair _pair) {
        pair = _pair;

        token0 = _pair.token0();
        token1 = _pair.token1();

        price0CumulativeLast = _pair.price0CumulativeLast();
        price1CumulativeLast = _pair.price1CumulativeLast();
        (, , blockTimestampLast) = _pair.getReserves();
    }

    function update() external {
        (
            uint price0Cumulative,
            uint price1Cumulative,
            uint32 blockTimestamp
        ) = UniswapV2OracleLibrary.currentCumulativePrices(address(pair));

        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        if (timeElapsed < PERIOD) {
            revert InvalidPeriod();
        }

        unchecked {
            price0Average = FixedPoint.uq112x112(
                uint224((price0Cumulative - price0CumulativeLast) / timeElapsed)
            );
            price1Average = FixedPoint.uq112x112(
                uint224((price1Cumulative - price1CumulativeLast) / timeElapsed)
            );
        }

        price0CumulativeLast = price0Cumulative;
        price1CumulativeLast = price1Cumulative;
        blockTimestampLast = blockTimestamp;
    }

    function consult(
        address token,
        uint amountIn
    ) external view returns (uint amountOut) {
        if (token == token0) {
            amountOut = price0Average.mul(amountIn).decode144();
        } else if (token == token1) {
            amountOut = price1Average.mul(amountIn).decode144();
        } else {
            revert InvalidToken();
        }
    }
}
