// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../src/UniswapV2Factory.sol";
import "../src/UniswapV2Pair.sol";
import "../src/libraries/UQ112x112.sol";
import "../src/libraries/Math.sol";
import {ERC20} from "../src/test/ERC20.sol";
import "forge-std/Test.sol";

contract UniswapV2ERC20Test is Test {
    using SafeMath for uint256;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    UniswapV2Factory public factory;
    ERC20 public token0;
    ERC20 public token1;
    UniswapV2Pair public pair;

    uint256 ownerPrivateKey;

    address owner;

    function setUp() public {
        ownerPrivateKey = 0x1234567890123456789012345678901234567890123456789012345678901234;
        owner = vm.addr(ownerPrivateKey);

        vm.startPrank(owner);

        factory = new UniswapV2Factory(owner);
        token0 = new ERC20(100000e18);
        token1 = new ERC20(100000e18);

        if (address(token0) > address(token1)) {
            (token0, token1) = (token1, token0);
        }

        address pairAddress = factory.createPair(address(token0), address(token1));

        pair = UniswapV2Pair(pairAddress);

        vm.stopPrank();
    }

    function test_Mint() public {
        uint256 token0Amount = 1e19;
        uint256 token1Amount = 4e19;

        vm.startPrank(owner);
        token0.transfer(address(pair), token0Amount);
        token1.transfer(address(pair), token1Amount);

        uint256 minimumLiquidity = pair.MINIMUM_LIQUIDITY();
        uint256 expectedLiquidity = 2e19 - minimumLiquidity;

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), address(0), minimumLiquidity);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), owner, expectedLiquidity);
        vm.expectEmit(true, true, true, true);
        emit Sync(uint112(token0Amount), uint112(token1Amount));
        vm.expectEmit(true, true, true, true);
        emit Mint(owner, token0Amount, token1Amount);

        uint256 liquidity = pair.mint(owner);

        vm.stopPrank();

        assertEq(expectedLiquidity, liquidity);
        assertEq(pair.totalSupply(), expectedLiquidity + minimumLiquidity);
        assertEq(pair.balanceOf(owner), expectedLiquidity);
        assertEq(token0.balanceOf(address(pair)), token0Amount);
        assertEq(token1.balanceOf(address(pair)), token1Amount);

        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        assertEq(reserve0, token0Amount);
        assertEq(reserve1, token1Amount);
    }

    function test_MintToActivePool() public {
        uint256 token0Amount = 1e19;
        uint256 token1Amount = 4e19;

        uint256 liquidityBefore = addLiquidity(token0Amount, token1Amount);

        // second mint
        vm.startPrank(owner);
        token0.transfer(address(pair), token0Amount);
        token1.transfer(address(pair), token1Amount);

        uint256 totalSupply = pair.totalSupply();

        uint256 expectedLiquidity =
            Math.min(token0Amount.mul(totalSupply) / token0Amount, token1Amount.mul(totalSupply) / token1Amount);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), owner, expectedLiquidity);
        vm.expectEmit(true, true, true, true);
        emit Sync(uint112(token0Amount + token0Amount), uint112(token1Amount + token1Amount));
        vm.expectEmit(true, true, true, true);
        emit Mint(owner, token0Amount, token1Amount);

        uint256 liquidity = pair.mint(owner);

        vm.stopPrank();

        assertEq(liquidity, expectedLiquidity);
        assertEq(pair.totalSupply(), totalSupply + expectedLiquidity);
        assertEq(pair.balanceOf(owner), liquidityBefore + expectedLiquidity);
        assertEq(token0.balanceOf(address(pair)), token0Amount + token0Amount);
        assertEq(token1.balanceOf(address(pair)), token1Amount + token1Amount);

        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        assertEq(reserve0, token0Amount + token0Amount);
        assertEq(reserve1, token1Amount + token1Amount);
    }

    function test_SwapToken0() public {
        uint256 token0Amount = 5e19;
        uint256 token1Amount = 10e19;

        addLiquidity(token0Amount, token1Amount);

        uint256 swapAmount = 1e19;
        uint256 expectedOutputAmount = 16524979156244789060;

        vm.startPrank(owner);

        token0.transfer(address(pair), swapAmount);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(pair), owner, expectedOutputAmount);
        vm.expectEmit(true, true, true, true);
        emit Sync(uint112(token0Amount + swapAmount), uint112(token1Amount - expectedOutputAmount));
        vm.expectEmit(true, true, true, true);
        emit Swap(owner, swapAmount, 0, 0, expectedOutputAmount, owner);

        pair.swap(0, expectedOutputAmount, owner, new bytes(0));

        vm.stopPrank();

        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        assertEq(reserve0, token0Amount + swapAmount);
        assertEq(reserve1, token1Amount - expectedOutputAmount);
        assertEq(token0.balanceOf(address(pair)), token0Amount + swapAmount);
        assertEq(token1.balanceOf(address(pair)), token1Amount - expectedOutputAmount);

        uint256 totalSupplyToken0 = token0.totalSupply();
        uint256 totalSupplyToken1 = token1.totalSupply();

        assertEq(token0.balanceOf(owner), totalSupplyToken0 - token0Amount - swapAmount);
        assertEq(token1.balanceOf(owner), totalSupplyToken1 - token1Amount + expectedOutputAmount);
    }

    function test_SwapToken1() public {
        uint256 token0Amount = 5e19;
        uint256 token1Amount = 10e19;

        addLiquidity(token0Amount, token1Amount);

        uint256 swapAmount = 1e19;
        uint256 expectedOutputAmount = 453305446940074565;

        vm.startPrank(owner);

        token1.transfer(address(pair), swapAmount);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(pair), owner, expectedOutputAmount);
        vm.expectEmit(true, true, true, true);
        emit Sync(uint112(token0Amount - expectedOutputAmount), uint112(token1Amount + swapAmount));
        vm.expectEmit(true, true, true, true);
        emit Swap(owner, 0, swapAmount, expectedOutputAmount, 0, owner);

        pair.swap(expectedOutputAmount, 0, owner, new bytes(0));

        vm.stopPrank();

        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        assertEq(reserve0, token0Amount - expectedOutputAmount);
        assertEq(reserve1, token1Amount + swapAmount);
        assertEq(token0.balanceOf(address(pair)), token0Amount - expectedOutputAmount);
        assertEq(token1.balanceOf(address(pair)), token1Amount + swapAmount);

        uint256 totalSupplyToken0 = token0.totalSupply();
        uint256 totalSupplyToken1 = token1.totalSupply();

        assertEq(token0.balanceOf(owner), totalSupplyToken0 - token0Amount + expectedOutputAmount);
        assertEq(token1.balanceOf(owner), totalSupplyToken1 - token1Amount - swapAmount);
    }

    function test_Burn() public {
        uint256 token0Amount = 3e19;
        uint256 token1Amount = 3e19;

        uint256 liquidity = addLiquidity(token0Amount, token1Amount);

        vm.startPrank(owner);

        pair.transfer(address(pair), liquidity);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(pair), address(0), liquidity);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(pair), owner, token0Amount - 1000);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(pair), owner, token1Amount - 1000);
        vm.expectEmit(true, true, true, true);
        emit Sync(1000, 1000);
        vm.expectEmit(true, true, true, true);
        emit Burn(owner, token0Amount - 1000, token1Amount - 1000, owner);

        (uint256 return0Amount, uint256 return1Amount) = pair.burn(owner);

        vm.stopPrank();

        assertEq(pair.totalSupply(), pair.MINIMUM_LIQUIDITY());
        assertEq(pair.balanceOf(owner), 0);
        assertEq(token0.balanceOf(address(pair)), 1000);
        assertEq(token1.balanceOf(address(pair)), 1000);
        assertEq(return0Amount, token0Amount - 1000);
        assertEq(return1Amount, token1Amount - 1000);
    }

    function test_CumulativeLast() public {
        uint256 token0Amount = 3e19;
        uint256 token1Amount = 3e19;

        addLiquidity(token0Amount, token1Amount);

        (,, uint32 blockTimestamp) = pair.getReserves();

        // pretend to mine a block
        vm.roll(block.number + 1);
        vm.warp(blockTimestamp + 1);

        pair.sync(); // update price0CumulativeLast and price1CumulativeLast

        (uint224 initialPrice0, uint224 initialPrice1) = encodePrice(uint112(token0Amount), uint112(token1Amount));

        assertEq(pair.price0CumulativeLast(), initialPrice0);
        assertEq(pair.price1CumulativeLast(), initialPrice1);

        (,, uint32 blockTimestampLast) = pair.getReserves();

        assertEq(blockTimestampLast, blockTimestamp + 1);

        uint256 swapAmount = 30e18;

        vm.startPrank(owner);
        token0.transfer(address(pair), swapAmount);

        // pretend to mine a block
        vm.roll(block.number + 1);
        vm.warp(blockTimestamp + 10);

        pair.swap(0, 10e18, owner, new bytes(0));

        vm.stopPrank();

        assertEq(pair.price0CumulativeLast(), initialPrice0 * 10);
        assertEq(pair.price1CumulativeLast(), initialPrice1 * 10);

        (,, blockTimestampLast) = pair.getReserves();

        assertEq(blockTimestampLast, blockTimestamp + 10);

        // pretend to mine a block
        vm.roll(block.number + 1);
        vm.warp(blockTimestamp + 20);

        pair.sync(); // update price0CumulativeLast and price1CumulativeLast

        (uint224 newPrice0, uint224 newPrice1) = encodePrice(60e18, 20e18);

        assertEq(pair.price0CumulativeLast(), initialPrice0 * 10 + newPrice0 * 10);
        assertEq(pair.price1CumulativeLast(), initialPrice1 * 10 + newPrice1 * 10);

        (,, blockTimestampLast) = pair.getReserves();

        assertEq(blockTimestampLast, blockTimestamp + 20);
    }

    function test_FeeToOff() public {
        uint256 token0Amount = 10000e18;
        uint256 token1Amount = 10000e18;

        addLiquidity(token0Amount, token1Amount);

        uint256 swapAmount = 10e18;
        uint256 expectedOutputAmount = 996006981039903216;

        vm.startPrank(owner);

        token1.transfer(address(pair), swapAmount);
        pair.swap(expectedOutputAmount, 0, owner, new bytes(0));

        uint256 expectedLiquidity = 10000e18;
        uint256 minimumLiquidity = pair.MINIMUM_LIQUIDITY();

        pair.transfer(address(pair), expectedLiquidity - minimumLiquidity);
        pair.burn(owner);

        vm.stopPrank();

        assertEq(pair.totalSupply(), minimumLiquidity);
    }

    function test_FeeToOn() public {
        address feeTo = vm.addr(1);

        vm.prank(owner);
        factory.setFeeTo(feeTo);

        uint256 token0Amount = 1000e19;
        uint256 token1Amount = 1000e19;

        addLiquidity(token0Amount, token1Amount);

        uint256 swapAmount = 1e19;
        uint256 expectedOutputAmount = 996006981039903216;

        vm.startPrank(owner);

        token1.transfer(address(pair), swapAmount);
        pair.swap(expectedOutputAmount, 0, owner, new bytes(0));

        uint256 minimumLiquidity = pair.MINIMUM_LIQUIDITY();
        uint256 expectedLiquidity = 1000e19 - minimumLiquidity;

        pair.transfer(address(pair), expectedLiquidity);
        (uint256 return0Amount, uint256 return1Amount) = pair.burn(owner);

        vm.stopPrank();

        uint256 expectedLiquidityOnFee = 749799759298893433;

        assertEq(pair.totalSupply(), minimumLiquidity + expectedLiquidityOnFee);
        assertEq(pair.balanceOf(feeTo), expectedLiquidityOnFee);
        assertEq(token0.balanceOf(address(pair)), token0Amount - expectedOutputAmount - return0Amount);
        assertEq(token1.balanceOf(address(pair)), token1Amount + swapAmount - return1Amount);
    }

    function addLiquidity(uint256 amount0, uint256 amount1) public returns (uint256 liquidity) {
        vm.startPrank(owner);
        token0.transfer(address(pair), amount0);
        token1.transfer(address(pair), amount1);

        liquidity = pair.mint(owner);

        vm.stopPrank();
    }

    function encodePrice(uint112 reserve0, uint112 reserve1) public pure returns (uint224, uint224) {
        return (
            UQ112x112.uqdiv(UQ112x112.encode(reserve1), reserve0), UQ112x112.uqdiv(UQ112x112.encode(reserve0), reserve1)
        );
    }
}
