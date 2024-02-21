// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../interfaces/IUniswapV2Callee.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IERC20.sol";

contract SimpleFlashSwap is IUniswapV2Callee {
    error InvalidPair();
    error InvalidToken();
    error InvalidAmount();

    IUniswapV2Pair public immutable pair;
    address public immutable token0;
    address public immutable token1;

    constructor(IUniswapV2Pair _pair) {
        pair = _pair;
        token0 = _pair.token0();
        token1 = _pair.token1();
    }

    function flashSwap(
        address tokenBorrow,
        uint256 amount,
        bool feeOn
    ) external {
        if (tokenBorrow != token0 && tokenBorrow != token1) {
            revert InvalidToken();
        }

        (uint amount0Out, uint amount1Out) = tokenBorrow == token0
            ? (amount, uint(0))
            : (uint(0), amount);

        bytes memory data = encodeData(tokenBorrow, amount, feeOn);
        pair.swap(amount0Out, amount1Out, address(this), data);
    }

    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external override {
        if (msg.sender != address(pair) || sender != address(this)) {
            revert InvalidPair();
        }

        (address tokenBorrow, uint256 amount, bool feeOn) = decodeData(data);

        if (tokenBorrow != token0 && tokenBorrow != token1) {
            revert InvalidToken();
        }

        if (amount != amount0 && amount != amount1) {
            revert InvalidAmount();
        }

        uint returnAmount = amount;

        if (feeOn) {
            uint fee = calculateFee(amount);
            returnAmount = amount + fee;
        }

        IERC20(tokenBorrow).transfer(address(pair), returnAmount);
    }

    function encodeData(
        address tokenBorrow,
        uint256 amount,
        bool feeOn
    ) public pure returns (bytes memory) {
        return abi.encode(tokenBorrow, amount, feeOn);
    }

    function decodeData(
        bytes calldata data
    ) public pure returns (address, uint256, bool) {
        return abi.decode(data, (address, uint256, bool));
    }

    // about 0.3% fee
    function calculateFee(uint256 amount) public pure returns (uint256) {
        return ((amount * 3) / 997) + 1;
    }

    receive() external payable {}
}
