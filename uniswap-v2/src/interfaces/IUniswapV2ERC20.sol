// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// 유동성 예치 시에 제공되는 LP 토큰의 ERC20 표준 인터페이스
interface IUniswapV2ERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value); // Approval 이벤트 (owner가 spender에게 value만큼의 토큰을 인출할 수 있도록 허가)
    event Transfer(address indexed from, address indexed to, uint256 value); // Transfer 이벤트 (from에서 to로 value만큼의 토큰을 전송)

    function name() external pure returns (string memory); // 토큰 이름 (getter)

    function symbol() external pure returns (string memory); // 토큰 심볼 (getter)

    function decimals() external pure returns (uint8); // 토큰 소수점 자리수 / ether의 경우 18 (getter)

    function totalSupply() external view returns (uint256); // 토큰 총 발행량 (getter)

    function balanceOf(address owner) external view returns (uint256); // owner의 토큰 잔액 (getter)

    function allowance(address owner, address spender) external view returns (uint256); // owner가 spender에게 인출을 허가한 토큰의 잔액 (getter)

    function approve(address spender, uint256 value) external returns (bool); // spender에게 value만큼의 토큰을 인출할 수 있도록 허가

    function transfer(address to, uint256 value) external returns (bool); // to에게 value만큼의 토큰을 전송

    function transferFrom(address from, address to, uint256 value) external returns (bool); // from에서 to에게 value만큼의 토큰을 전송

    function DOMAIN_SEPARATOR() external view returns (bytes32); // EIP-2612 permit()을 위한 도메인 분리자

    function PERMIT_TYPEHASH() external pure returns (bytes32); // EIP-2612 permit()을 위한 타입 해시

    function nonces(address owner) external view returns (uint256); // EIP-2612 permit()을 위한 nonce

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external; // EIP-2612 permit()을 통한 토큰 인출 허가
}
