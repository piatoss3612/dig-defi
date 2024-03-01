// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/interfaces/IUniswapV2Pair.sol";
import "../src/examples/SimpleOracle.sol";
import "../src/test/ERC20.sol";
import "../src/UniswapV2Router01.sol";
import "../src/UniswapV2Factory.sol";
import "../src/UniswapV2Pair.sol";
import "../src/libraries/UniswapV2Library.sol";

contract SimpleOracleTest is Test {
    UniswapV2Router01 public router;
    UniswapV2Factory public factory;
    UniswapV2Pair public pair;
    UniswapV2ERC20WithMint public token0;
    UniswapV2ERC20WithMint public token1;
    SimpleOracle public oracle;

    uint256 public constant INIT_SUPPLY = 1000000e18;

    function setUp() public {
        token0 = new UniswapV2ERC20WithMint();
        token1 = new UniswapV2ERC20WithMint();

        (token0, token1) = token0 < token1 ? (token0, token1) : (token1, token0);

        token0.mint(address(this), INIT_SUPPLY);
        token1.mint(address(this), INIT_SUPPLY);

        factory = new UniswapV2Factory(address(this));
        router = new UniswapV2Router01(address(factory), address(0));
        pair = UniswapV2Pair(factory.createPair(address(token0), address(token1)));

        vm.label(address(token0), "token0");
        vm.label(address(token1), "token1");
        vm.label(address(factory), "factory");
        vm.label(address(router), "router");
        vm.label(address(pair), "pair");

        token0.approve(address(router), type(uint256).max);
        token1.approve(address(router), type(uint256).max);

        (uint256 amountA, uint256 amountB, uint256 liquidity) = router.addLiquidity(
            address(token0),
            address(token1),
            INIT_SUPPLY / 2,
            INIT_SUPPLY / 2,
            INIT_SUPPLY / 2,
            INIT_SUPPLY / 2,
            address(this),
            block.timestamp
        );

        assertEq(amountA, INIT_SUPPLY / 2);
        assertEq(amountB, INIT_SUPPLY / 2);
        assertEq(liquidity, INIT_SUPPLY / 2 - 1000);

        oracle = new SimpleOracle(IUniswapV2Pair(address(pair)));
        vm.label(address(oracle), "oracle");
    }

    function test_Update() public {
        uint256 price0CumulativeLast = oracle.price0CumulativeLast();
        uint256 price1CumulativeLast = oracle.price1CumulativeLast();
        uint32 blockTimestampLast = oracle.blockTimestampLast();

        assertEq(price0CumulativeLast, 0);
        assertEq(price1CumulativeLast, 0);
        assertEq(blockTimestampLast, block.timestamp);

        uint256 amount1Out = oracle.consult(address(token0), 1000e18);

        assertEq(amount1Out, 0);

        vm.warp(block.timestamp + oracle.PERIOD());
        vm.roll(block.number + 1);

        address[] memory path = new address[](2);
        path[0] = address(token0);
        path[1] = address(token1);
        router.swapExactTokensForTokens(1000e18, 0, path, address(this), block.timestamp + 1000);

        oracle.update();

        amount1Out = oracle.consult(address(token0), 1000e18);

        assertGt(amount1Out, 0);

        vm.warp(block.timestamp + oracle.PERIOD());
        vm.roll(block.number + 1);

        router.swapExactTokensForTokens(1000e18, 0, path, address(this), block.timestamp + 1000);

        oracle.update();

        uint256 newAmount1Out = oracle.consult(address(token0), 1000e18);

        assertGt(amount1Out, newAmount1Out);
        assertGt(newAmount1Out, 0);
    }
}
