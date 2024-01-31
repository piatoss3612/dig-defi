// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    ); // 페어 생성 이벤트

    function feeTo() external view returns (address); // 수수료를 받을 주소를 반환

    function feeToSetter() external view returns (address); // 수수료를 받을 주소를 설정할 수 있는 주소를 반환

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair); // 토큰 A와 토큰 B의 쌍을 입력하면 해당 토큰 쌍의 유동성 풀 주소를 반환

    function allPairs(uint) external view returns (address pair); // 모든 토큰 쌍의 유동성 풀 주소를 저장하는 배열에서 index에 해당하는 주소를 반환

    function allPairsLength() external view returns (uint); // 유동성 풀의 개수를 반환

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair); // 토큰 A와 토큰 B의 쌍을 입력하면 해당 토큰 쌍의 유동성 풀을 생성하고, 해당 컨트랙트 주소를 반환

    function setFeeTo(address) external; // 수수료를 받을 주소를 설정

    function setFeeToSetter(address) external; // 수수료를 받을 주소를 설정할 수 있는 주소를 설정
}
