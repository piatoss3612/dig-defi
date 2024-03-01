// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// UniswapV2Callee 인터페이스 (아직 정확히 무슨 역할을 하는지는 모르겠음)
interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}
