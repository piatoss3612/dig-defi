// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// ERC20 표준 인터페이스
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value); // Approval 이벤트 (owner가 spender에게 value만큼의 토큰을 인출할 수 있도록 허가)
    event Transfer(address indexed from, address indexed to, uint256 value); // Transfer 이벤트 (from에서 to로 value만큼의 토큰을 전송)

    function name() external view returns (string memory); // 토큰 이름 (getter)

    function symbol() external view returns (string memory); // 토큰 심볼 (getter)

    function decimals() external view returns (uint8); // 토큰 소수점 자리수 / ether의 경우 18 (getter)

    function totalSupply() external view returns (uint256); // 토큰 총 발행량 (getter)

    function balanceOf(address owner) external view returns (uint256); // owner의 토큰 잔액 (getter)

    function allowance(address owner, address spender) external view returns (uint256); // owner가 spender에게 인출을 허가한 토큰의 잔액 (getter)

    function approve(address spender, uint256 value) external returns (bool); // spender에게 value만큼의 토큰을 인출할 수 있도록 허가

    function transfer(address to, uint256 value) external returns (bool); // to에게 value만큼의 토큰을 전송

    function transferFrom(address from, address to, uint256 value) external returns (bool); // from에서 to에게 value만큼의 토큰을 전송
}
