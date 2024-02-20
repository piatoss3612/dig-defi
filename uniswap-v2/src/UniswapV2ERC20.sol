// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./interfaces/IUniswapV2ERC20.sol";
import "./libraries/SafeMath.sol";

// IUniswapV2ERC20 구현 (LP 토큰)
contract UniswapV2ERC20 is IUniswapV2ERC20 {
    using SafeMath for uint;

    /*
        상태 변수 선언
     */
    string public constant name = "Uniswap V2";
    string public constant symbol = "UNI-V2";
    uint8 public constant decimals = 18;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9; // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    mapping(address => uint) public nonces;

    constructor() {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)), // name
                keccak256(bytes("1")), // version
                chainId, // chainId
                address(this) // verifyingContract
            )
        ); // EIP2612 domain separator (replay attack 방지)
    }

    /*
        내부 함수 선언
     */

    // to에게 value만큼의 토큰을 발행
    function _mint(address to, uint value) internal {
        totalSupply += value; // 총 발행량 증가
        balanceOf[to] += value; // to의 잔고 증가
        emit Transfer(address(0), to, value); // 이벤트 발생
    }

    // from의 토큰을 value만큼 소각
    function _burn(address from, uint value) internal {
        balanceOf[from] -= value; // from의 잔고 감소
        totalSupply -= value; // 총 발행량 감소
        emit Transfer(from, address(0), value); // 이벤트 발생
    }

    // owner가 spender에게 value만큼의 토큰을 사용할 수 있도록 허락
    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value; // allowance 갱신
        emit Approval(owner, spender, value); // 이벤트 발생
    }

    // from에서 to로 value만큼의 토큰을 전송
    function _transfer(address from, address to, uint value) private {
        balanceOf[from] -= value; // from의 잔고 감소
        balanceOf[to] += value; // to의 잔고 증가
        emit Transfer(from, to, value); // 이벤트 발생
    }

    /*
        공개 함수 선언
     */
    // spender가 value만큼의 토큰을 사용할 수 있도록 허락
    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    // to에게 value만큼의 토큰을 전송
    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    // from에서 to로 value만큼의 토큰을 전송
    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool) {
        if (allowance[from][msg.sender] != type(uint).max) {
            // 무제한 허가가 아닌 경우 (허가량이 제한되어 있는 경우)
            allowance[from][msg.sender] -= value; // 허가량 감소
        }
        _transfer(from, to, value); // from의 잔고에서 to로 value만큼의 토큰 전송
        return true;
    }

    // owner가 spender에게 토큰을 사용할 수 있도록 허락
    // (approve는 소유 계정에서 직접 호출해야 한다면, permit은 서명을 통해 유효성을 검증할 수 있으므로 제삼자가 호출할 수 있다.)
    function permit(
        address owner, // 서명자
        address spender, // 허락 받는자
        uint value, // 허락하는 토큰의 양
        uint deadline, // 허락 기한 (type(uint).max: 무제한)
        uint8 v, // 서명의 v
        bytes32 r, // 서명의 r
        bytes32 s // 서명의 s
    ) external {
        require(deadline >= block.timestamp, "UniswapV2: EXPIRED"); // 기한이 현 시각보다 이전인 경우 예외 처리
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner]++, // 논스 증가
                        deadline
                    )
                )
            )
        ); // 서명 데이터
        address recoveredAddress = ecrecover(digest, v, r, s); // 서명자 주소 복원 (= digest에 서명한 비공개 키의 공개 키)
        require(
            recoveredAddress != address(0) && recoveredAddress == owner, // 서명자 주소가 0이 아니고 서명자가 서명자 주소와 같아야 한다.
            "UniswapV2: INVALID_SIGNATURE"
        );
        _approve(owner, spender, value); // owner가 spender에게 value만큼의 토큰을 사용할 수 있도록 허락
    }
}
