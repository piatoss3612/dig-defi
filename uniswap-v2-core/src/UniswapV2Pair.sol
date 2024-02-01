// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./interfaces/IUniswapV2Pair.sol";
import "./UniswapV2ERC20.sol";
import "./libraries/Math.sol";
import "./libraries/UQ112x112.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Callee.sol";

contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    using SafeMath for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10 ** 3; // 최소 유동성 (1,000)
    bytes4 private constant SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)"))); // transfer 함수의 selector (transfer.selector를 사용할 수도 있음)

    address public factory; // 팩토리 컨트랙트 주소
    address public token0; // 토큰0 주소
    address public token1; // 토큰1 주소

    // 세 개의 상태 변수가 단일 스토리지 슬롯을 사용 (112 + 112 + 32 = 256 bits)
    uint112 private reserve0; // 토큰0의 보유량 (추적된 토큰0의 보유량)
    uint112 private reserve1; // 토큰1의 보유량 (추적된 토큰1의 보유량)
    uint32 private blockTimestampLast; // 마지막 업데이트 시간

    uint public price0CumulativeLast; // 토큰0의 누적 가격
    uint public price1CumulativeLast; // 토큰1의 누적 가격
    uint public kLast; // 마지막으로 유동성 풀이 업데이트된 이후의 상수 k

    // Reentrancy Guard
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "UniswapV2: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    // 보유량과 마지막 업데이트 시간을 반환
    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    // 현 컨트랙트에서 to로 value만큼의 토큰을 안전하게 전송
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "UniswapV2: TRANSFER_FAILED"
        );
    }

    // 생성자
    constructor() UniswapV2ERC20() {
        factory = msg.sender; // 팩토리 컨트랙트 주소를 저장
    }

    // 팩토리 컨트랙트에서 초기화를 위해 한 번만 호출
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "UniswapV2: FORBIDDEN"); // 팩토리 컨트랙트만 호출 가능
        token0 = _token0; // 토큰0 주소를 저장
        token1 = _token1; // 토큰1 주소를 저장
    }

    // 토큰0과 토큰1의 보유량을 업데이트, 블록당 첫 호출 시 가격 누적값도 업데이트
    function _update(
        uint balance0, // 새로운 토큰0의 보유량
        uint balance1, // 새로운 토큰1의 보유량
        uint112 _reserve0, // 기존의 토큰0의 보유량
        uint112 _reserve1 // 기존의 토큰1의 보유량
    ) private {
        require(
            balance0 <= type(uint112).max && balance1 <= type(uint112).max,
            "UniswapV2: OVERFLOW"
        ); // uint112 타입의 최댓값보다 보유량이 크면 에러
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32); // unix timestamp를 32비트로 변환
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // 마지막 업데이트 시간과 현재 블록의 시간 차이
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // 마지막 업데이트 시간과 현재 블록의 시간 차이가 0보다 크다 = 서로 다른 블록에서의 업데이트
            // 즉, 새로운 블록에서 첫 번째 업데이트인 경우,
            // 토큰0과 토큰1의 보유량이 0이 아니면 가격 누적값을 업데이트 (현 블록에서 처음 호출된 경우)

            // * never overflows, and + overflow is desired (derised? 오히려 좋다는 뜻?)
            price0CumulativeLast +=
                uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                timeElapsed; // price0 = reserve1 / reserve0, price0CumulativeLast += price0 * timeElapsed
            price1CumulativeLast +=
                uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                timeElapsed; // price1 = reserve0 / reserve1, price1CumulativeLast += price1 * timeElapsed
        }
        reserve0 = uint112(balance0); // 토큰0의 보유량을 업데이트
        reserve1 = uint112(balance1); // 토큰1의 보유량을 업데이트
        blockTimestampLast = blockTimestamp; // 현재 블록에서의 업데이트 시간을 업데이트
        emit Sync(reserve0, reserve1); // Sync 이벤트 발생
    }

    // 수수료가 적용되면, 상수 k의 sqrt(k)의 증가량의 1/6에 해당하는 수량의 UniswapV2ERC20 토큰을 수수료 수취인 주소로 전송
    function _mintFee(
        uint112 _reserve0, // 기존의 토큰0의 보유량
        uint112 _reserve1 // 기존의 토큰1의 보유량
    ) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(factory).feeTo(); // 수수료 수취인 주소
        feeOn = feeTo != address(0); // 수수료 수취인 주소가 0이 아니면 수수료가 적용되는 것
        uint _kLast = kLast; // kLast를 불러옴
        if (feeOn) {
            // 수수료 수취인 주소가 설정되어 있는 경우에만 수행
            if (_kLast != 0) {
                // 지난번 유동성 변경 이후의 상수 k가 0이 아니면
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1)); // rootK = sqrt(reserve0 * reserve1)
                uint rootKLast = Math.sqrt(_kLast); // rootKLast = sqrt(kLast)

                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast)); // numerator = totalSupply * (sqrt(reserve0 * reserve1) - sqrt(kLast))
                    uint denominator = rootK.mul(5).add(rootKLast); // denominator = 5 * sqrt(reserve0 * reserve1) + sqrt(kLast)
                    uint liquidity = numerator / denominator; // liquidity = numerator / denominator = totalSupply * (sqrt(reserve0 * reserve1) - sqrt(kLast)) / (5 * sqrt(reserve0 * reserve1) + sqrt(kLast))
                    if (liquidity > 0) _mint(feeTo, liquidity); // 수수료 수취인 주소로 liquidity만큼의 LP토큰을 전송
                }
            }
        } else if (_kLast != 0) {
            // 수수료 수취인 주소가 설정되어 있지 않고, 지난번 유동성 변경 이후의 상수 k가 0이 아니면
            kLast = 0; // 상수 k를 0으로 업데이트
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // 추적된 토큰0과 토큰1의 보유량
        uint balance0 = IERC20(token0).balanceOf(address(this)); // 현재 토큰0의 보유량 (새롭게 유동성 풀에 공급된 토큰0의 보유량이 포함될 수 있음)
        uint balance1 = IERC20(token1).balanceOf(address(this)); // 현재 토큰1의 보유량 (새롭게 유동성 풀에 공급된 토큰1의 보유량이 포함될 수 있음)
        uint amount0 = balance0.sub(_reserve0); // 새롭게 유동성 풀에 공급된 토큰0의 보유량
        uint amount1 = balance1.sub(_reserve1); // 새롭게 유동성 풀에 공급된 토큰1의 보유량

        bool feeOn = _mintFee(_reserve0, _reserve1); // 수수료가 적용되는지 확인
        uint _totalSupply = totalSupply; // _mintFee 함수에서 totalSupply를 업데이트할 수 있으므로, 호출하고 난 후에 불러와야 함
        if (_totalSupply == 0) {
            // 유동성 공급이 처음인 경우 (처음 LP 토큰을 발행하는 경우)
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY); // liquidity = sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY
            _mint(address(0), MINIMUM_LIQUIDITY); // MINIMUM_LIQUIDITY만큼의 UniswapV2ERC20 토큰을 0번 주소로 전송 (영구적으로 잠금)
        } else {
            liquidity = Math.min(
                amount0.mul(_totalSupply) / _reserve0,
                amount1.mul(_totalSupply) / _reserve1
            ); // liquidity = min(amount0 * totalSupply / reserve0, amount1 * totalSupply / reserve1)
        }
        require(liquidity > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED"); // 유동성 공급량이 0이면 에러 반환
        _mint(to, liquidity); // to로 liquidity만큼의 LP 토큰을 전송

        _update(balance0, balance1, _reserve0, _reserve1); // 토큰0과 토큰1의 보유량을 업데이트
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // 수수료가 적용되면, 최근 상수 k를 업데이트
        emit Mint(msg.sender, amount0, amount1); // Mint 이벤트 발생
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(
        address to
    ) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // 추적된 토큰0과 토큰1의 보유량
        address _token0 = token0; // gas savings (토큰0 주소)
        address _token1 = token1; // gas savings (토큰1 주소)
        uint balance0 = IERC20(_token0).balanceOf(address(this)); // 현재 토큰0의 보유량 (추적되지 않은 보유량이 포함될 수 있음)
        uint balance1 = IERC20(_token1).balanceOf(address(this)); // 현재 토큰1의 보유량 (추적되지 않은 보유량이 포함될 수 있음)
        uint liquidity = balanceOf[address(this)]; // 현재 컨트랙트의 LP 토큰 보유량 (= to가 반환한 LP 토큰의 수량)

        bool feeOn = _mintFee(_reserve0, _reserve1); // 수수료가 적용되는지 확인
        uint _totalSupply = totalSupply; // _mintFee 함수에서 수수료가 발행되면 totalSupply가 업데이트될 수 있으므로, 호출하고 난 후에 불러와야 함
        amount0 = liquidity.mul(balance0) / _totalSupply; // 유동성 풀에서 인출할 토큰0의 수량 (pro-rata distribution)
        amount1 = liquidity.mul(balance1) / _totalSupply; // 유동성 풀에서 인출할 토큰1의 수량 (pro-rata distribution)
        require(
            amount0 > 0 && amount1 > 0,
            "UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED"
        ); // 어느 하나라도 0이면 에러
        _burn(address(this), liquidity); // 반환된 LP 토큰을 소각
        _safeTransfer(_token0, to, amount0); // to로 amount0만큼의 토큰0을 전송
        _safeTransfer(_token1, to, amount1); // to로 amount1만큼의 토큰1을 전송
        balance0 = IERC20(_token0).balanceOf(address(this)); // 현재 토큰0의 보유량 (추적되지 않은 보유량이 포함될 수 있음)
        balance1 = IERC20(_token1).balanceOf(address(this)); // 현재 토큰1의 보유량 (추적되지 않은 보유량이 포함될 수 있음)

        _update(balance0, balance1, _reserve0, _reserve1); // 토큰0과 토큰1의 보유량을 업데이트
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0와 reserve1이 업데이트되었으므로, 최근 상수 k를 업데이트
        emit Burn(msg.sender, amount0, amount1, to); // Burn 이벤트 발생
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(
        uint amount0Out, // 풀에서 빠져나갈 토큰0의 수량
        uint amount1Out, // 풀에서 빠져나갈 토큰1의 수량
        address to, // 토큰을 전송할 주소
        bytes calldata data // IUniswapV2Callee.uniswapV2Call()을 호출하기 위한 데이터
    ) external lock {
        require(
            amount0Out > 0 || amount1Out > 0,
            "UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT"
        ); // 토큰0과 토큰1의 수량이 모두 0이면 에러
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // 추적된 토큰0과 토큰1의 보유량
        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "UniswapV2: INSUFFICIENT_LIQUIDITY"
        ); // 토큰0과 토큰1의 보유량보다 많은 수량을 빼려고 하면 에러

        uint balance0;
        uint balance1;
        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "UniswapV2: INVALID_TO"); // to가 토큰0이나 토큰1의 주소면 에러
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // 낙관적으로 토큰0을 to로 전송
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // 낙관적으로 토큰1을 to로 전송
            if (data.length > 0)
                IUniswapV2Callee(to).uniswapV2Call(
                    msg.sender,
                    amount0Out,
                    amount1Out,
                    data
                ); // to가 IUniswapV2Callee 인터페이스를 구현한 컨트랙트인 경우, uniswapV2Call() 함수를 호출
            balance0 = IERC20(_token0).balanceOf(address(this)); // 현재 토큰0의 보유량 (swap() 함수 호출로 인해 토큰0의 보유량에 변동이 있을 수 있음)
            balance1 = IERC20(_token1).balanceOf(address(this)); // 현재 토큰1의 보유량 (swap() 함수 호출로 인해 토큰1의 보유량에 변동이 있을 수 있음)
        }
        uint amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0; // swap을 통해 유동성 풀에 추가된 토큰0의 수량
        uint amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0; // swap을 통해 유동성 풀에 추가된 토큰1의 수량
        require(
            amount0In > 0 || amount1In > 0,
            "UniswapV2: INSUFFICIENT_INPUT_AMOUNT"
        ); // swap을 통해 유동성 풀에 추가된 토큰0과 토큰1의 수량이 하나라도 0이면 에러 반환
        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3)); // balance0Adjusted = balance0 * 1000 - amount0In * 3
            uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3)); // balance1Adjusted = balance1 * 1000 - amount1In * 3
            require(
                balance0Adjusted.mul(balance1Adjusted) >=
                    uint(_reserve0).mul(_reserve1).mul(1000 ** 2), // balance0Adjusted * balance1Adjusted = (balance0 * 1000 - amount0In * 3) * (balance1 * 1000 - amount1In * 3) >= reserve0 * reserve1 * 1000^2
                "UniswapV2: K"
            ); // 상수 k가 변하지 않도록 체크
        }

        _update(balance0, balance1, _reserve0, _reserve1); // 토큰0과 토큰1의 보유량을 업데이트 (k는 변하지 않음)
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to); // Swap 이벤트 발생
    }

    // 실제 토큰0과 토큰1의 보유량이 추적된 토큰0과 토큰1의 보유량과 일치하도록 남은 토큰을 to로 전송
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(
            _token0,
            to,
            IERC20(_token0).balanceOf(address(this)).sub(reserve0)
        );
        _safeTransfer(
            _token1,
            to,
            IERC20(_token1).balanceOf(address(this)).sub(reserve1)
        );
    }

    // 추적된 토큰0과 토큰1의 보유량을  토큰0과 토큰1의 보유량으로 업데이트 (추적되지 않은 보유량이 포함될 수 있음)
    function sync() external lock {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0,
            reserve1
        );
    }
}
