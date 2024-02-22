// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../interfaces/IUniswapV2Callee.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IERC20.sol";

contract SimpleFlashSwap is IUniswapV2Callee {
    error OnlyOwner();
    error InvalidPair();
    error InvalidToken();
    error InvalidAmount();

    address public owner;

    IUniswapV2Pair public immutable pair;
    address public immutable token0;
    address public immutable token1;

    constructor(IUniswapV2Pair _pair) {
        owner = msg.sender;
        pair = _pair;
        token0 = _pair.token0();
        token1 = _pair.token1();
    }

    function withdraw(address token, uint256 amount) external returns (bool) {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }

        if (token != token0 && token != token1) {
            revert InvalidToken();
        }

        return IERC20(token).transfer(owner, amount);
    }

    function flashSwap(
        address tokenBorrow,
        address tokenRepay,
        uint256 amount
    ) external {
        if (tokenBorrow != token0 && tokenBorrow != token1) {
            revert InvalidToken();
        }

        if (tokenRepay != token0 && tokenRepay != token1) {
            revert InvalidToken();
        }

        if (amount == 0) {
            revert InvalidAmount();
        }

        (uint amount0Out, uint amount1Out) = tokenBorrow == token0
            ? (amount, uint(0))
            : (uint(0), amount);

        bytes memory data = encodeData(tokenBorrow, tokenRepay, amount);
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

        (address tokenBorrow, address tokenRepay, uint256 amount) = decodeData(
            data
        );

        if (tokenBorrow != token0 && tokenBorrow != token1) {
            revert InvalidToken();
        }

        if (tokenRepay != token0 && tokenRepay != token1) {
            revert InvalidToken();
        }

        if (amount != amount0 && amount != amount1) {
            revert InvalidAmount();
        }

        uint repayAmount;

        if (tokenBorrow == tokenRepay) {
            repayAmount = repayWithSameToken(amount);
        } else {
            repayAmount = repayWithDifferentToken(tokenBorrow, amount);
        }

        IERC20(tokenRepay).transfer(address(pair), repayAmount);
    }

    function encodeData(
        address tokenBorrow,
        address tokenRepay,
        uint256 amount
    ) public pure returns (bytes memory) {
        return abi.encode(tokenBorrow, tokenRepay, amount);
    }

    function decodeData(
        bytes calldata data
    )
        public
        pure
        returns (address tokenBorrow, address tokenRepay, uint256 amount)
    {
        return abi.decode(data, (address, address, uint256));
    }
    // about 0.3009% fee
    function repayWithSameToken(
        uint256 amount
    ) public pure returns (uint256 repayAmount) {
        repayAmount = (amount * 1000) / 997 + 1;
    }

    function repayWithDifferentToken(
        address tokenBorrow,
        uint256 amount
    ) public view returns (uint256 repayAmount) {
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        (uint256 amount0Out, uint256 amount1Out) = tokenBorrow == token0
            ? (amount, uint256(0))
            : (uint256(0), amount);

        uint numerator;
        uint denominator;

        if (amount0Out > 0) {
            numerator = amount0Out * reserve1 * 1000;
            denominator = (reserve0 - amount0Out) * 997;
        } else {
            numerator = amount1Out * reserve0 * 1000;
            denominator = (reserve1 - amount1Out) * 997;
        }

        repayAmount = (numerator / denominator) + 1;
    }

    receive() external payable {}
}
