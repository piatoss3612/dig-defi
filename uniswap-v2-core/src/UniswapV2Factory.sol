// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./interfaces/IUniswapV2Factory.sol";
import "./UniswapV2Pair.sol";

contract UniswapV2Factory is IUniswapV2Factory {
    address public feeTo; // feeTo는 수수료를 받을 주소
    address public feeToSetter; // feeToSetter는 feeTo를 설정할 수 있는 주소

    mapping(address => mapping(address => address)) public getPair; // token0과 token1을 입력하면 해당 토큰 쌍의 UniswapV2Pair 컨트랙트 주소를 반환
    address[] public allPairs; // 모든 토큰 쌍의 UniswapV2Pair 컨트랙트 주소를 저장하는 배열

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter; // feeToSetter를 설정
    }

    // UniswapV2Pair 인스턴스의 개수를 반환
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    // 토큰 쌍의 UniswapV2Pair 컨트랙트를 생성하고, 해당 컨트랙트 주소를 반환
    function createPair(
        address tokenA, // 토큰 A의 주소
        address tokenB // 토큰 B의 주소
    ) external returns (address pair) {
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES"); // 토큰 A와 토큰 B의 주소가 같으면 에러
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA); // 토큰 A와 토큰 B의 주소를 오름차순으로 정렬
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS"); // 토큰 A의 주소가 0이면 에러
        require(
            getPair[token0][token1] == address(0),
            "UniswapV2: PAIR_EXISTS"
        ); // 토큰 A와 토큰 B의 쌍이 이미 존재하면 에러 (반대의 경우는 이미 정렬되어 있으므로 체크할 필요 없음)
        bytes memory bytecode = type(UniswapV2Pair).creationCode; // UniswapV2Pair 컨트랙트의 bytecode를 가져옴
        bytes32 salt = keccak256(abi.encodePacked(token0, token1)); // 토큰 A와 토큰 B의 주소를 인자로 해시값을 계산하여 salt로 사용
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt) // create2를 사용하여 UniswapV2Pair 컨트랙트를 생성
        }
        IUniswapV2Pair(pair).initialize(token0, token1); // UniswapV2Pair 컨트랙트의 initialize 함수를 호출하여 토큰 A와 토큰 B의 주소를 설정
        getPair[token0][token1] = pair; // mapping에 토큰 A와 토큰 B의 쌍을 저장
        getPair[token1][token0] = pair; // mapping에 토큰 B와 토큰 A의 쌍을 저장
        allPairs.push(pair); // allPairs 배열에 토큰 A와 토큰 B의 쌍을 저장
        emit PairCreated(token0, token1, pair, allPairs.length); // PairCreated 이벤트를 발생
    }

    // 수수료를 받을 주소를 설정
    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN"); // feeToSetter만 호출 가능
        feeTo = _feeTo;
    }

    // 수수료를 받을 주소를 설정할 수 있는 주소를 설정
    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN"); // feeToSetter만 호출 가능
        feeToSetter = _feeToSetter;
    }
}
