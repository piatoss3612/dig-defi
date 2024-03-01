// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./interfaces/IUniswapV2Factory.sol";
import "./libraries/TransferHelper.sol";

import "./libraries/UniswapV2Library.sol";
import "./interfaces/IUniswapV2Router01.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IWETH.sol";

contract UniswapV2Router01 is IUniswapV2Router01 {
    address public immutable override factory;
    address public immutable override WETH;

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "UniswapV2Router: EXPIRED");
        _;
    }

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** ADD LIQUIDITY ****
    /**
     * @dev 유동성 풀에 추가되는 토큰 A와 토큰 B의 양을 계산
     * @param tokenA 토큰 A의 주소
     * @param tokenB 토큰 B의 주소
     * @param amountADesired 토큰 A의 개수 상한
     * @param amountBDesired 토큰 B의 개수 상한
     * @param amountAMin 토큰 A의 개수 하한
     * @param amountBMin 토큰 B의 개수 하한
     */
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) private returns (uint256 amountA, uint256 amountB) {
        // 페어가 존재하지 않으면 새로 생성
        if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
            IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        }

        // 페어의 리저브를 가져옴
        (uint256 reserveA, uint256 reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);

        // 리저브가 0이면 desired 값으로 설정
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            // desiredA를 기준으로 토큰 B의 최적의 양을 계산
            uint256 amountBOptimal = UniswapV2Library.quote(amountADesired, reserveA, reserveB);
            // desiredB보다 optimalB가 작거나 같으면 optimalB가 최종 amountB
            if (amountBOptimal <= amountBDesired) {
                // optimalB가 최소 기준보다 크거나 같은지 확인
                require(amountBOptimal >= amountBMin, "UniswapV2Router: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                // optimalB가 desiredB보다 크면 desiredB를 기준으로 토큰 A의 최적의 양을 새로 계산
                uint256 amountAOptimal = UniswapV2Library.quote(amountBDesired, reserveB, reserveA);
                // optimalA가 desiredA보다 작거나 같은지 확인
                assert(amountAOptimal <= amountADesired);
                // optimalA가 최소 기준보다 크거나 같은지 확인
                require(amountAOptimal >= amountAMin, "UniswapV2Router: INSUFFICIENT_A_AMOUNT");
                // optimalA가 최종 amountA, desiredB가 최종 amountB
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    /**
     * @dev 토큰 A와 토큰 B를 유동성 풀에 추가
     * @param tokenA 토큰 A의 주소
     * @param tokenB 토큰 B의 주소
     * @param amountADesired 토큰 A의 개수 상한
     * @param amountBDesired 토큰 B의 개수 상한
     * @param amountAMin 토큰 A의 개수 하한
     * @param amountBMin 토큰 B의 개수 하한
     * @param to 유동성 토큰을 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     */
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        // 유동성 풀에 추가될 토큰 A와 토큰 B의 양을 계산
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        // 유동성 풀에 토큰 A와 토큰 B를 전송
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        // 유동성 토큰을 발행
        liquidity = IUniswapV2Pair(pair).mint(to);
    }

    /**
     * @dev 토큰 A와 ETH를 유동성 풀에 추가
     * @param token 토큰 A의 주소
     * @param amountTokenDesired 토큰 A의 개수 상한
     * @param amountTokenMin 토큰 A의 개수 하한
     * @param amountETHMin 이더리움의 개수 하한
     * @param to 유동성 토큰을 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     */
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable override ensure(deadline) returns (uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        // 유동성 풀에 추가될 토큰 A와 ETH의 양을 계산
        (amountToken, amountETH) =
            _addLiquidity(token, WETH, amountTokenDesired, msg.value, amountTokenMin, amountETHMin);
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        // 토큰 A를 유동성 풀에 전송
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        // ETH를 WETH로 전환하여 유동성 풀에 전송
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        // 유동성 토큰을 발행
        liquidity = IUniswapV2Pair(pair).mint(to);
        // 남은 ETH를 반환
        if (msg.value > amountETH) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
        } // refund dust eth, if any
    }

    // **** REMOVE LIQUIDITY ****
    /**
     * @dev 유동성 풀에서 토큰 A와 토큰 B를 제거
     * @param tokenA  토큰 A의 주소
     * @param tokenB 토큰 B의 주소
     * @param liquidity 유동성 토큰의 개수
     * @param amountAMin 토큰 A의 개수 하한
     * @param amountBMin 토큰 B의 개수 하한
     * @param to 토큰 A와 토큰 B를 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     * @return amountA 토큰 A의 개수
     * @return amountB 토큰 B의 개수
     */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) public override ensure(deadline) returns (uint256 amountA, uint256 amountB) {
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);

        IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity); // 유동성 토큰을 페어로 전송
        (uint256 amount0, uint256 amount1) = IUniswapV2Pair(pair).burn(to); // 토큰 A와 토큰 B를 받음
        (address token0,) = UniswapV2Library.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);

        require(amountA >= amountAMin, "UniswapV2Router: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "UniswapV2Router: INSUFFICIENT_B_AMOUNT");
    }

    /**
     * @dev 유동성 풀에서 토큰 A와 ETH를 제거
     * @param token 토큰 A의 주소
     * @param liquidity 유동성 토큰의 개수
     * @param amountTokenMin 토큰 A의 개수 하한
     * @param amountETHMin 이더리움의 개수 하한
     * @param to 토큰 A와 ETH를 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     * @return amountToken 토큰 A의 개수
     * @return amountETH 이더리움의 개수
     */
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public override ensure(deadline) returns (uint256 amountToken, uint256 amountETH) {
        // 유동성 풀에서 토큰 A와 ETH를 제거하고 라우터 컨트랙트가 토큰 A와 ETH를 받음
        (amountToken, amountETH) =
            removeLiquidity(token, WETH, liquidity, amountTokenMin, amountETHMin, address(this), deadline);
        TransferHelper.safeTransfer(token, to, amountToken); // 토큰을 to에 전송
        IWETH(WETH).withdraw(amountETH); // WETH를 ETH로 전환
        TransferHelper.safeTransferETH(to, amountETH); // ETH를 to에 전송
    }

    /**
     * @dev 유동성 풀에서 토큰 A와 토큰 B를 제거하면서 permit을 통해 허용
     * @param tokenA 토큰 A의 주소
     * @param tokenB 토큰 B의 주소
     * @param liquidity 유동성 토큰의 개수
     * @param amountAMin 토큰 A의 개수 하한
     * @param amountBMin 토큰 B의 개수 하한
     * @param to 토큰 A와 토큰 B를 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     * @param approveMax permit 함수 호출 시 허용할 유동성 토큰의 개수
     * @param v permit 함수 호출 시 v 값
     * @param r permit 함수 호출 시 r 값
     * @param s permit 함수 호출 시 s 값
     * @return amountA  토큰 A의 개수
     * @return amountB 토큰 B의 개수
     */
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override returns (uint256 amountA, uint256 amountB) {
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        uint256 value = approveMax ? type(uint256).max : liquidity; // approveMax가 true면 uint의 최대값, 아니면 liquidity
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s); // permit 함수 호출해 라우터가 대신 유동성 토큰을 전송할 수 있도록 허용

        // 유동성 풀에서 토큰 A와 토큰 B를 제거
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    /**
     * @dev 유동성 풀에서 토큰 A와 ETH를 제거하면서 permit을 통해 허용
     * @param token 토큰 A의 주소
     * @param liquidity 유동성 토큰의 개수
     * @param amountTokenMin 토큰 A의 개수 하한
     * @param amountETHMin 이더리움의 개수 하한
     * @param to 토큰 A와 ETH를 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     * @param approveMax permit 함수 호출 시 허용할 유동성 토큰의 개수
     * @param v permit 함수 호출 시 v 값
     * @param r permit 함수 호출 시 r 값
     * @param s permit 함수 호출 시 s 값
     * @return amountToken 토큰 A의 개수
     * @return amountETH 이더리움의 개수
     */
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override returns (uint256 amountToken, uint256 amountETH) {
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair

    /**
     * @dev 여러 경로를 통해 토큰을 교환하고 최종적으로 _to에 전송
     * @param amounts 교환할 토큰의 양 배열
     * @param path 토큰을 교환할 토큰 컨트랙트의 주소 배열
     * @param _to  최종 수신자
     */
    function _swap(uint256[] memory amounts, address[] memory path, address _to) private {
        // path[0]을 amounts[0]만큼 path[0]-path[1] 페어로 전송해 놓은 상태에서 시작
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]); // i번째 토큰을 i+1번째 토큰으로 교환
            (address token0,) = UniswapV2Library.sortTokens(input, output); // 토큰 컨트랙트 주소를 정렬
            uint256 amountOut = amounts[i + 1]; // 교환할 토큰의 양
            (uint256 amount0Out, uint256 amount1Out) =
                input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0)); // 정렬된 컨트랙트 주소에 따라 amount0Out, amount1Out 설정
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to; // output을 전송할 주소 설정
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

    /**
     * @dev 토큰 A를 토큰 B로 교환
     * @param amountIn 토큰 A의 개수
     * @param amountOutMin 토큰 B의 개수 하한
     * @param path 토큰 A와 토큰 B를 교환하는 과정에서 거쳐가는 토큰 컨트랙트의 주소 배열
     * @param to 토큰 B를 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     * @return amounts 교환된 토큰의 양 배열
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256[] memory amounts) {
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path); // 교환할 토큰의 양 배열을 가져옴
        require(
            amounts[amounts.length - 1] >= amountOutMin, // 교환된 토큰의 양이 하한보다 크거나 같은지 확인
            "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        ); // 토큰 A를 교환할 페어로 전송
        _swap(amounts, path, to); // 토큰 A를 토큰 B로 교환
    }

    /**
     * @dev 토큰 A를 토큰 B로 교환
     * @param amountOut 토큰 B의 개수
     * @param amountInMax 토큰 A의 개수 상한
     * @param path 토큰 A와 토큰 B를 교환하는 과정에서 거쳐가는 토큰 컨트랙트의 주소 배열
     * @param to 토큰 B를 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     * @return amounts 교환된 토큰의 양 배열
     */
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256[] memory amounts) {
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path); // 교환할 토큰의 양 배열을 가져옴
        require(
            amounts[0] <= amountInMax, // 교환할 토큰의 양이 상한보다 작거나 같은지 확인
            "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        ); // 토큰 A를 교환할 페어로 전송
        _swap(amounts, path, to); // 토큰 A를 토큰 B로 교환
    }

    /**
     * @dev ETH를 토큰으로 교환
     * @param amountOutMin 토큰의 개수 하한
     * @param path ETH와 토큰을 교환하는 과정에서 거쳐가는 토큰 컨트랙트의 주소 배열
     * @param to 토큰을 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     * @return amounts 교환된 토큰의 양 배열
     */
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WETH, "UniswapV2Router: INVALID_PATH");
        amounts = UniswapV2Library.getAmountsOut(factory, msg.value, path); // 교환할 토큰의 양 배열을 가져옴
        require(
            amounts[amounts.length - 1] >= amountOutMin, // 교환된 토큰의 양이 하한보다 크거나 같은지 확인
            "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWETH(WETH).deposit{value: amounts[0]}(); // ETH를 WETH로 전환
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0])); // WETH를 교환할 페어로 전송
        _swap(amounts, path, to); // WETH를 토큰으로 교환
    }

    /**
     * @dev 토큰을 ETH로 교환
     * @param amountOut ETH의 개수
     * @param amountInMax 토큰의 개수 상한
     * @param path 토큰과 ETH를 교환하는 과정에서 거쳐가는 토큰 컨트랙트의 주소 배열
     * @param to ETH를 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     * @return amounts 교환된 토큰의 양 배열
     */
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256[] memory amounts) {
        require(path[path.length - 1] == WETH, "UniswapV2Router: INVALID_PATH"); // path의 마지막 토큰이 WETH인지 확인
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path); // 교환할 토큰의 양 배열을 가져옴
        require(
            amounts[0] <= amountInMax, // 교환할 토큰의 양이 상한보다 작거나 같은지 확인
            "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        ); // 토큰을 교환할 페어로 전송
        _swap(amounts, path, address(this)); // 토큰을 WETH로 교환
        IWETH(WETH).withdraw(amounts[amounts.length - 1]); // WETH를 ETH로 전환
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]); // ETH를 to에 전송
    }

    /**
     * @dev 토큰 A를 ETH로 교환
     * @param amountIn 토큰 A의 개수
     * @param amountOutMin ETH의 개수 하한
     * @param path 토큰 A와 ETH를 교환하는 과정에서 거쳐가는 토큰 컨트랙트의 주소 배열
     * @param to ETH를 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     */
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256[] memory amounts) {
        require(path[path.length - 1] == WETH, "UniswapV2Router: INVALID_PATH"); // path의 마지막 토큰이 WETH인지 확인
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path); // 교환할 토큰의 양 배열을 가져옴
        require(
            amounts[amounts.length - 1] >= amountOutMin, // 교환된 토큰의 양이 하한보다 크거나 같은지 확인
            "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        ); // 토큰 A를 교환할 페어로 전송
        _swap(amounts, path, address(this)); // 토큰 A를 WETH로 교환
        IWETH(WETH).withdraw(amounts[amounts.length - 1]); // WETH를 ETH로 전환
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]); // ETH를 to에 전송
    }

    /**
     * @dev ETH를 토큰으로 교환
     * @param amountOut 토큰의 개수
     * @param path ETH와 토큰을 교환하는 과정에서 거쳐가는 토큰 컨트랙트의 주소 배열
     * @param to 토큰을 받을 주소
     * @param deadline 함수 호출이 유효한 기간
     */
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WETH, "UniswapV2Router: INVALID_PATH"); // path의 첫 번째 토큰이 WETH인지 확인
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path); // 교환할 토큰의 양 배열을 가져옴
        require(amounts[0] <= msg.value, "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"); // 교환할 토큰의 양이 msg.value보다 작거나 같은지 확인
        IWETH(WETH).deposit{value: amounts[0]}(); // ETH를 WETH로 전환
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0])); // WETH를 교환할 페어로 전송
        _swap(amounts, path, to); // WETH를 토큰으로 교환
        if (msg.value > amounts[0]) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
        } // refund dust eth, if any
    }

    /**
     * @dev 토큰 A의 가격을 계산
     * @param amountA 토큰 A의 개수
     * @param reserveA 토큰 A의 리저브
     * @param reserveB 토큰 B의 리저브
     * @return amountB 토큰 B의 개수
     */
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB)
        public
        pure
        override
        returns (uint256 amountB)
    {
        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    /**
     * @dev 입력 토큰의 양과 리저브, 출력 토큰의 리저브를 통해 출력 토큰의 양을 계산
     * @param amountIn 입력 토큰의 양
     * @param reserveIn 입력 토큰의 리저브
     * @param reserveOut 출력 토큰의 리저브
     * @return amountOut 출력 토큰의 양
     */
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        public
        pure
        override
        returns (uint256 amountOut)
    {
        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    /**
     * @dev 출력 토큰의 양과 리저브, 입력 토큰의 리저브를 통해 입력 토큰의 양을 계산
     * @param amountOut 출력 토큰의 양
     * @param reserveIn 입력 토큰의 리저브
     * @param reserveOut 출력 토큰의 리저브
     * @return amountIn 입력 토큰의 양
     */
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        public
        pure
        override
        returns (uint256 amountIn)
    {
        return UniswapV2Library.getAmountOut(amountOut, reserveIn, reserveOut);
    }

    /**
     * @dev 입력 토큰의 양과 경로를 통해 출력 토큰의 양을 계산
     * @param amountIn 입력 토큰의 양
     * @param path 토큰을 교환하는 과정에서 거쳐가는 토큰 컨트랙트의 주소 배열
     * @return amounts 출력 토큰의 양 배열
     */
    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        override
        returns (uint256[] memory amounts)
    {
        return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    /**
     * @dev 출력 토큰의 양과 경로를 통해 입력 토큰의 양을 계산
     * @param amountOut 출력 토큰의 양
     * @param path 토큰을 교환하는 과정에서 거쳐가는 토큰 컨트랙트의 주소 배열
     * @return amounts 입력 토큰의 양 배열
     */
    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        override
        returns (uint256[] memory amounts)
    {
        return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }
}
