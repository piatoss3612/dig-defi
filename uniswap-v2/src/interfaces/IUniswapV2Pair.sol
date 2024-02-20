// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// 유동성 풀의 토큰 쌍을 나타내는 인터페이스
interface IUniswapV2Pair {
    // solidity v0.8.0 이상에서는 상속 문제로 인해 UniswapV2ERC20와 충돌이 발생하므로 주석 처리

    event Approval(address indexed owner, address indexed spender, uint value); // Approval 이벤트 (owner가 spender에게 value만큼의 토큰을 인출할 수 있도록 허가)
    event Transfer(address indexed from, address indexed to, uint value); // Transfer 이벤트 (from에서 to로 value만큼의 토큰을 전송)

    function name() external pure returns (string memory); // 토큰 이름 (getter)

    function symbol() external pure returns (string memory); // 토큰 심볼 (getter)

    function decimals() external pure returns (uint8); // 토큰 소수점 자리수 / ether의 경우 18 (getter)

    function balanceOf(address owner) external view returns (uint); // owner의 토큰 잔액 (getter)

    function totalSupply() external view returns (uint); // 토큰의 총 공급량 (getter)

    function allowance(
        address owner,
        address spender
    ) external view returns (uint); // owner가 spender에게 인출을 허가한 토큰의 잔액 (getter)

    function approve(address spender, uint value) external returns (bool); // spender에게 value만큼의 토큰을 인출할 수 있도록 허가

    function transfer(address to, uint value) external returns (bool); // to에게 value만큼의 토큰을 전송

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool); // from에서 to에게 value만큼의 토큰을 전송

    function DOMAIN_SEPARATOR() external view returns (bytes32); // EIP-2612 permit()을 위한 도메인 구분자

    function PERMIT_TYPEHASH() external pure returns (bytes32); // EIP-2612 permit()을 위한 타입 해시

    function nonces(address owner) external view returns (uint); // EIP-2612 permit()을 위한 nonce

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external; // EIP-2612 permit()을 통한 토큰 인출 허가

    event Mint(address indexed sender, uint amount0, uint amount1); // Mint 이벤트 (sender가 amount0만큼의 token0과 amount1만큼의 token1을 유동성 풀에 추가)
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    ); // Burn 이벤트 (sender가 amount0만큼의 token0과 amount1만큼의 token1을 유동성 풀에서 인출)
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    ); // Swap 이벤트 (sender가 amount0In만큼의 token0과 amount1In만큼의 token1을 유동성 풀에 추가하고, amount0Out만큼의 token0과 amount1Out만큼의 token1을 유동성 풀에서 인출)
    event Sync(uint112 reserve0, uint112 reserve1); // Sync 이벤트 (reserve0와 reserve1을 동기화)

    function MINIMUM_LIQUIDITY() external pure returns (uint); // 최소 유동성

    function factory() external view returns (address); // 팩토리 주소 (getter)

    function token0() external view returns (address); // 토큰0 주소 (getter)

    function token1() external view returns (address); // 토큰1 주소 (getter)

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast); // 토큰0과 토큰1의 잔액과 마지막 업데이트 시간 (getter)

    function price0CumulativeLast() external view returns (uint); // 토큰0의 누적 가격 (getter)

    function price1CumulativeLast() external view returns (uint); // 토큰1의 누적 가격 (getter)

    function kLast() external view returns (uint); // 상수 k의 마지막 값 (getter)

    function mint(address to) external returns (uint liquidity); // to에게 토큰을 발행

    function burn(address to) external returns (uint amount0, uint amount1); // to에게 토큰을 인출

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external; // to에게 amount0Out만큼의 token0과 amount1Out만큼의 token1을 일정한 비율로 스왑 (data는 IUniswapV2Callee.uniswapV2Call()을 호출하기 위한 데이터)

    function skim(address to) external; // to에게 토큰을 인출

    function sync() external; // 토큰0과 토큰1의 잔액과 마지막 업데이트 시간을 동기화

    function initialize(address, address) external; // 유동성 풀을 초기화
}
