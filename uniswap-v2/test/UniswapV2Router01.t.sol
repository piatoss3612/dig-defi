// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {MockToken} from "../src/mock/MockToken.sol";
import {MockWETH} from "../src/mock/MockWETH.sol";
import {UniswapV2Router01} from "../src/UniswapV2Router01.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import "../src/libraries/UniswapV2Library.sol";

contract UniswapV2Router01Test is Test {
    uint256 constant MAX = type(uint256).max;
    address constant ZERO_ADDRESS = address(0);
    uint256 constant MINIMUM_LIQUIDITY = 1000;

    Utilities utils;
    MockToken token0;
    MockToken token1;
    MockWETH weth;
    MockToken wethPartner;
    UniswapV2Factory factory;
    UniswapV2Router01 router;
    UniswapV2Pair pair;
    UniswapV2Pair wethPair;

    address feeToSetter;
    uint256 playerPrivateKey;
    address player;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
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

    function setUp() public {
        utils = new Utilities();
        vm.label(address(utils), "Utilities");

        address payable[] memory users = utils.createUsers(1);

        feeToSetter = users[0];
        playerPrivateKey = utils.createPrivateKey();
        player = utils.addressFromPrivateKey(playerPrivateKey);
        utils.fundUser(payable(player), utils.expandTo18Decimals(100));

        token0 = new MockToken("MockToken", "MT");
        token1 = new MockToken("MockToken", "MT");
        (token0, token1) = token0 < token1 ? (token0, token1) : (token1, token0);

        weth = new MockWETH();
        wethPartner = new MockToken("WETH Pair", "WP");
        factory = new UniswapV2Factory(feeToSetter);
        router = new UniswapV2Router01(address(factory), address(weth));
        pair = UniswapV2Pair(factory.createPair(address(token0), address(token1)));
        wethPair = UniswapV2Pair(factory.createPair(address(weth), address(wethPartner)));

        vm.label(feeToSetter, "Fee To Setter");
        vm.label(player, "Player");
        vm.label(address(token0), "Token0");
        vm.label(address(token1), "Token1");
        vm.label(address(weth), "WETH");
        vm.label(address(wethPartner), "WETH Partner");
        vm.label(address(factory), "Factory");
        vm.label(address(router), "Router");
        vm.label(address(pair), "Pair");
        vm.label(address(wethPair), "WETH Pair");

        token0.mint(player, utils.expandTo18Decimals(10000));
        token1.mint(player, utils.expandTo18Decimals(10000));
        wethPartner.mint(player, utils.expandTo18Decimals(10000));
    }

    function test_AddLiquidity() public {
        uint256 token0Amount = utils.expandTo18Decimals(1);
        uint256 token1Amount = utils.expandTo18Decimals(4);

        uint256 expectedLiquidity = utils.expandTo18Decimals(2);

        vm.startPrank(player);
        token0.approve(address(router), MAX);
        token1.approve(address(router), MAX);

        vm.expectEmit(true, true, true, true, address(token0));
        emit Transfer(player, address(pair), token0Amount);
        vm.expectEmit(true, true, true, true, address(token1));
        emit Transfer(player, address(pair), token1Amount);
        vm.expectEmit(true, true, true, true, address(pair));
        emit Transfer(ZERO_ADDRESS, ZERO_ADDRESS, MINIMUM_LIQUIDITY);
        vm.expectEmit(true, true, true, true, address(pair));
        emit Transfer(ZERO_ADDRESS, player, expectedLiquidity - MINIMUM_LIQUIDITY);
        vm.expectEmit(true, true, true, true, address(pair));
        emit Sync(uint112(token0Amount), uint112(token1Amount));
        vm.expectEmit(true, true, true, true, address(pair));
        emit Mint(address(router), token0Amount, token1Amount);

        (uint256 amount0, uint256 amount1, uint256 liquidity) = router.addLiquidity(
            address(token0), address(token1), token0Amount, token1Amount, 0, 0, player, block.timestamp + 100
        );

        vm.stopPrank();

        assertEq(amount0, token0Amount);
        assertEq(amount1, token1Amount);
        assertEq(liquidity, expectedLiquidity - MINIMUM_LIQUIDITY);
        assertEq(pair.balanceOf(player), expectedLiquidity - MINIMUM_LIQUIDITY);
    }

    function test_AddLiquidityETH() public {
        uint256 wethPartnerAmount = utils.expandTo18Decimals(1);
        uint256 ethAmount = utils.expandTo18Decimals(4);

        uint256 expectedLiquidity = utils.expandTo18Decimals(2);

        vm.startPrank(player);

        wethPartner.approve(address(router), MAX);

        address wethPairToken0 = pair.token0();

        vm.expectEmit(true, true, true, true, address(wethPartner));
        emit Transfer(player, address(wethPair), wethPartnerAmount);
        vm.expectEmit(true, true, true, true, address(weth));
        emit Deposit(address(router), ethAmount);
        vm.expectEmit(true, true, true, true, address(weth));
        emit Transfer(address(router), address(wethPair), ethAmount);
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Transfer(ZERO_ADDRESS, ZERO_ADDRESS, MINIMUM_LIQUIDITY);
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Transfer(ZERO_ADDRESS, player, expectedLiquidity - MINIMUM_LIQUIDITY);
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Sync(
            wethPairToken0 == address(wethPartner) ? uint112(wethPartnerAmount) : uint112(ethAmount),
            wethPairToken0 == address(wethPartner) ? uint112(ethAmount) : uint112(wethPartnerAmount)
        );
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Mint(
            address(router),
            wethPairToken0 == address(wethPartner) ? wethPartnerAmount : ethAmount,
            wethPairToken0 == address(wethPartner) ? ethAmount : wethPartnerAmount
        );

        (uint256 amountToken, uint256 amountETH, uint256 liquidity) = router.addLiquidityETH{value: ethAmount}(
            address(wethPartner), wethPartnerAmount, 0, 0, address(player), block.timestamp + 100
        );

        vm.stopPrank();

        assertEq(amountToken, wethPartnerAmount);
        assertEq(amountETH, ethAmount);
        assertEq(liquidity, expectedLiquidity - MINIMUM_LIQUIDITY);
        assertEq(wethPair.balanceOf(player), expectedLiquidity - MINIMUM_LIQUIDITY);
    }

    function test_RemoveLiquidity() public {
        uint256 token0Amount = utils.expandTo18Decimals(1);
        uint256 token1Amount = utils.expandTo18Decimals(4);
        addLiquidity(token0Amount, token1Amount);

        uint256 expectedLiquidity = utils.expandTo18Decimals(2);

        vm.startPrank(player);

        pair.approve(address(router), MAX);

        vm.expectEmit(true, true, true, true, address(pair));
        emit Transfer(player, address(pair), expectedLiquidity - MINIMUM_LIQUIDITY);
        vm.expectEmit(true, true, true, true, address(pair));
        emit Transfer(address(pair), ZERO_ADDRESS, expectedLiquidity - MINIMUM_LIQUIDITY);
        vm.expectEmit(true, true, true, true, address(token0));
        emit Transfer(address(pair), player, token0Amount - 500);
        vm.expectEmit(true, true, true, true, address(token1));
        emit Transfer(address(pair), player, token1Amount - 2000);
        vm.expectEmit(true, true, true, true, address(pair));
        emit Sync(uint112(500), uint112(2000));
        vm.expectEmit(true, true, true, true, address(pair));
        emit Burn(address(router), token0Amount - 500, token1Amount - 2000, player);

        (uint256 amountA, uint256 amountB) = router.removeLiquidity(
            address(token0), address(token1), expectedLiquidity - MINIMUM_LIQUIDITY, 0, 0, player, block.timestamp + 100
        );

        vm.stopPrank();

        assertEq(amountA, token0Amount - 500);
        assertEq(amountB, token1Amount - 2000);
        assertEq(pair.balanceOf(player), 0);
    }

    function test_RemoveLiquidityETH() public {
        uint256 wethPartnerAmount = utils.expandTo18Decimals(1);
        uint256 ethAmount = utils.expandTo18Decimals(4);

        vm.startPrank(player);
        wethPartner.transfer(address(wethPair), wethPartnerAmount);
        weth.deposit{value: ethAmount}();
        weth.transfer(address(wethPair), ethAmount);
        wethPair.mint(player);

        uint256 expectedLiquidity = utils.expandTo18Decimals(2);
        address wethPairToken0 = wethPair.token0();
        wethPair.approve(address(router), MAX);

        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Transfer(player, address(wethPair), expectedLiquidity - MINIMUM_LIQUIDITY);
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Transfer(address(wethPair), ZERO_ADDRESS, expectedLiquidity - MINIMUM_LIQUIDITY);
        vm.expectEmit(true, true, true, true, address(weth));
        emit Transfer(address(wethPair), address(router), ethAmount - 2000);
        vm.expectEmit(true, true, true, true, address(wethPartner));
        emit Transfer(address(wethPair), address(router), wethPartnerAmount - 500);
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Sync(
            wethPairToken0 == address(wethPartner) ? uint112(500) : uint112(2000),
            wethPairToken0 == address(wethPartner) ? uint112(2000) : uint112(500)
        );
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Burn(
            address(router),
            wethPairToken0 == address(wethPartner) ? wethPartnerAmount - 500 : ethAmount - 2000,
            wethPairToken0 == address(wethPartner) ? ethAmount - 2000 : wethPartnerAmount - 500,
            address(router)
        );
        vm.expectEmit(true, true, true, true, address(wethPartner));
        emit Transfer(address(router), player, wethPartnerAmount - 500);
        vm.expectEmit(true, true, true, true, address(weth));
        emit Withdrawal(address(router), ethAmount - 2000);

        (uint256 amountToken, uint256 amountETH) = router.removeLiquidityETH(
            address(wethPartner), expectedLiquidity - MINIMUM_LIQUIDITY, 0, 0, player, block.timestamp + 100
        );

        vm.stopPrank();

        assertEq(amountToken, wethPartnerAmount - 500);
        assertEq(amountETH, ethAmount - 2000);
        assertEq(wethPair.balanceOf(player), 0);
        assertEq(weth.balanceOf(player), 0);
        assertEq(wethPartner.balanceOf(player), utils.expandTo18Decimals(10000) - 500);
        assertEq(player.balance, utils.expandTo18Decimals(100) - 2000);
    }

    function test_RemoveLiquidityWithPermit() public {
        uint256 token0Amount = utils.expandTo18Decimals(1);
        uint256 token1Amount = utils.expandTo18Decimals(4);
        addLiquidity(token0Amount, token1Amount);

        uint256 expectedLiquidity = utils.expandTo18Decimals(2);

        vm.startPrank(player);

        uint256 nonce = pair.nonces(player);
        bytes32 digest = utils.calcDigest(
            player,
            address(router),
            expectedLiquidity - MINIMUM_LIQUIDITY,
            nonce,
            pair.DOMAIN_SEPARATOR(),
            pair.PERMIT_TYPEHASH(),
            block.timestamp + 100
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerPrivateKey, digest);

        router.removeLiquidityWithPermit(
            address(token0),
            address(token1),
            expectedLiquidity - MINIMUM_LIQUIDITY,
            0,
            0,
            player,
            block.timestamp + 100,
            false,
            v,
            r,
            s
        );

        vm.stopPrank();
    }

    function test_RemoveLiquidityETHWithPermit() public {
        uint256 wethPartnerAmount = utils.expandTo18Decimals(1);
        uint256 ethAmount = utils.expandTo18Decimals(4);

        vm.startPrank(player);
        wethPartner.transfer(address(wethPair), wethPartnerAmount);
        weth.deposit{value: ethAmount}();
        weth.transfer(address(wethPair), ethAmount);
        wethPair.mint(player);

        uint256 expectedLiquidity = utils.expandTo18Decimals(2);

        uint256 nonce = wethPair.nonces(player);
        bytes32 digest = utils.calcDigest(
            player,
            address(router),
            expectedLiquidity - MINIMUM_LIQUIDITY,
            nonce,
            wethPair.DOMAIN_SEPARATOR(),
            wethPair.PERMIT_TYPEHASH(),
            block.timestamp + 100
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerPrivateKey, digest);

        router.removeLiquidityETHWithPermit(
            address(wethPartner),
            expectedLiquidity - MINIMUM_LIQUIDITY,
            0,
            0,
            player,
            block.timestamp + 100,
            false,
            v,
            r,
            s
        );

        vm.stopPrank();
    }

    function test_SwapExactTokensForTokens() public {
        uint256 token0Amount = utils.expandTo18Decimals(5);
        uint256 token1Amount = utils.expandTo18Decimals(10);
        uint256 swapAmount = utils.expandTo18Decimals(1);
        uint256 expectedOutputAmount = 1662497915624478906;

        addLiquidity(token0Amount, token1Amount);

        vm.startPrank(player);

        address[] memory path = new address[](2);
        path[0] = address(token0);
        path[1] = address(token1);

        vm.expectEmit(true, true, true, true, address(token0));
        emit Transfer(player, address(pair), swapAmount);
        vm.expectEmit(true, true, true, true, address(token1));
        emit Transfer(address(pair), player, expectedOutputAmount);
        vm.expectEmit(true, true, true, true, address(pair));
        emit Sync(uint112(token0Amount + swapAmount), uint112(token1Amount - expectedOutputAmount));
        vm.expectEmit(true, true, true, true, address(pair));
        emit Swap(address(router), swapAmount, 0, 0, expectedOutputAmount, player);

        uint256[] memory amounts = router.swapExactTokensForTokens(swapAmount, 0, path, player, MAX);

        vm.stopPrank();

        assertEq(amounts[0], swapAmount);
        assertEq(amounts[1], expectedOutputAmount);
    }

    function test_SwapTokensForExactTokens() public {
        uint256 token0Amount = utils.expandTo18Decimals(5);
        uint256 token1Amount = utils.expandTo18Decimals(10);
        uint256 expectedSwapAmount = 557227237267357629;
        uint256 outputAmount = utils.expandTo18Decimals(1);

        addLiquidity(token0Amount, token1Amount);

        vm.startPrank(player);

        address[] memory path = new address[](2);
        path[0] = address(token0);
        path[1] = address(token1);

        vm.expectEmit(true, true, true, true, address(token0));
        emit Transfer(player, address(pair), expectedSwapAmount);
        vm.expectEmit(true, true, true, true, address(token1));
        emit Transfer(address(pair), player, outputAmount);
        vm.expectEmit(true, true, true, true, address(pair));
        emit Sync(uint112(token0Amount + expectedSwapAmount), uint112(token1Amount - outputAmount));
        vm.expectEmit(true, true, true, true, address(pair));
        emit Swap(address(router), expectedSwapAmount, 0, 0, outputAmount, player);

        uint256[] memory amounts = router.swapTokensForExactTokens(outputAmount, MAX, path, player, MAX);

        vm.stopPrank();

        assertEq(amounts[0], expectedSwapAmount);
        assertEq(amounts[1], outputAmount);
    }

    function test_SwapExactETHForTokens() public {
        uint256 wethPartnerAmount = utils.expandTo18Decimals(10);
        uint256 ethAmount = utils.expandTo18Decimals(5);
        uint256 swapAmount = utils.expandTo18Decimals(1);
        uint256 expectedOutputAmount = 1662497915624478906;

        vm.startPrank(player);

        wethPartner.transfer(address(wethPair), wethPartnerAmount);
        weth.deposit{value: ethAmount}();
        weth.transfer(address(wethPair), ethAmount);
        wethPair.mint(player);

        address wethPairToken0 = wethPair.token0();

        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(wethPartner);

        vm.expectEmit(true, true, true, true, address(weth));
        emit Deposit(address(router), swapAmount);
        vm.expectEmit(true, true, true, true, address(weth));
        emit Transfer(address(router), address(wethPair), swapAmount);
        vm.expectEmit(true, true, true, true, address(wethPartner));
        emit Transfer(address(wethPair), player, expectedOutputAmount);
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Sync(
            wethPairToken0 == address(wethPartner)
                ? uint112(wethPartnerAmount - expectedOutputAmount)
                : uint112(ethAmount + swapAmount),
            wethPairToken0 == address(wethPartner)
                ? uint112(ethAmount + swapAmount)
                : uint112(wethPartnerAmount - expectedOutputAmount)
        );
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Swap(
            address(router),
            wethPairToken0 == address(wethPartner) ? 0 : swapAmount,
            wethPairToken0 == address(wethPartner) ? swapAmount : 0,
            wethPairToken0 == address(wethPartner) ? expectedOutputAmount : 0,
            wethPairToken0 == address(wethPartner) ? 0 : expectedOutputAmount,
            player
        );

        uint256[] memory amounts = router.swapExactETHForTokens{value: swapAmount}(0, path, player, MAX);

        vm.stopPrank();

        assertEq(amounts[0], swapAmount);
        assertEq(amounts[1], expectedOutputAmount);
    }

    function test_SwapTokensForExactETH() public {
        uint256 wethPartnerAmount = utils.expandTo18Decimals(5);
        uint256 ethAmount = utils.expandTo18Decimals(10);
        uint256 expectedSwapAmount = 557227237267357629;
        uint256 outputAmount = utils.expandTo18Decimals(1);

        vm.startPrank(player);

        wethPartner.transfer(address(wethPair), wethPartnerAmount);
        weth.deposit{value: ethAmount}();
        weth.transfer(address(wethPair), ethAmount);
        wethPair.mint(player);

        wethPartner.approve(address(router), MAX);

        address wethPairToken0 = wethPair.token0();

        address[] memory path = new address[](2);
        path[0] = address(wethPartner);
        path[1] = address(weth);

        vm.expectEmit(true, true, true, true, address(wethPartner));
        emit Transfer(player, address(wethPair), expectedSwapAmount);
        vm.expectEmit(true, true, true, true, address(weth));
        emit Transfer(address(wethPair), address(router), outputAmount);
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Sync(
            wethPairToken0 == address(wethPartner)
                ? uint112(wethPartnerAmount + expectedSwapAmount)
                : uint112(ethAmount - outputAmount),
            wethPairToken0 == address(wethPartner)
                ? uint112(ethAmount - outputAmount)
                : uint112(wethPartnerAmount + expectedSwapAmount)
        );
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Swap(
            address(router),
            wethPairToken0 == address(wethPartner) ? expectedSwapAmount : 0,
            wethPairToken0 == address(wethPartner) ? 0 : expectedSwapAmount,
            wethPairToken0 == address(wethPartner) ? 0 : outputAmount,
            wethPairToken0 == address(wethPartner) ? outputAmount : 0,
            address(router)
        );
        vm.expectEmit(true, true, true, true, address(weth));
        emit Withdrawal(address(router), outputAmount);

        uint256[] memory amounts = router.swapTokensForExactETH(outputAmount, MAX, path, player, MAX);

        vm.stopPrank();

        assertEq(amounts[0], expectedSwapAmount);
        assertEq(amounts[1], outputAmount);
    }

    function test_SwapExactTokensForETH() public {
        uint256 wethPartnerAmount = utils.expandTo18Decimals(5);
        uint256 ethAmount = utils.expandTo18Decimals(10);
        uint256 swapAmount = utils.expandTo18Decimals(1);
        uint256 expectedOutputAmount = 1662497915624478906;

        vm.startPrank(player);

        wethPartner.transfer(address(wethPair), wethPartnerAmount);
        weth.deposit{value: ethAmount}();
        weth.transfer(address(wethPair), ethAmount);
        wethPair.mint(player);

        wethPartner.approve(address(router), MAX);

        address wethPairToken0 = wethPair.token0();

        address[] memory path = new address[](2);
        path[0] = address(wethPartner);
        path[1] = address(weth);

        vm.expectEmit(true, true, true, true, address(wethPartner));
        emit Transfer(player, address(wethPair), swapAmount);
        vm.expectEmit(true, true, true, true, address(weth));
        emit Transfer(address(wethPair), address(router), expectedOutputAmount);
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Sync(
            wethPairToken0 == address(wethPartner)
                ? uint112(wethPartnerAmount + swapAmount)
                : uint112(ethAmount - expectedOutputAmount),
            wethPairToken0 == address(wethPartner)
                ? uint112(ethAmount - expectedOutputAmount)
                : uint112(wethPartnerAmount + swapAmount)
        );
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Swap(
            address(router),
            wethPairToken0 == address(wethPartner) ? swapAmount : 0,
            wethPairToken0 == address(wethPartner) ? 0 : swapAmount,
            wethPairToken0 == address(wethPartner) ? 0 : expectedOutputAmount,
            wethPairToken0 == address(wethPartner) ? expectedOutputAmount : 0,
            address(router)
        );
        vm.expectEmit(true, true, true, true, address(weth));
        emit Withdrawal(address(router), expectedOutputAmount);

        uint256[] memory amounts = router.swapExactTokensForETH(swapAmount, 0, path, player, MAX);

        vm.stopPrank();

        assertEq(amounts[0], swapAmount);
        assertEq(amounts[1], expectedOutputAmount);
    }

    function test_SwapETHForExactTokens() public {
        uint256 wethPartnerAmount = utils.expandTo18Decimals(10);
        uint256 ethAmount = utils.expandTo18Decimals(5);
        uint256 expectedSwapAmount = 557227237267357629;
        uint256 outputAmount = utils.expandTo18Decimals(1);

        vm.startPrank(player);

        wethPartner.transfer(address(wethPair), wethPartnerAmount);
        weth.deposit{value: ethAmount}();
        weth.transfer(address(wethPair), ethAmount);
        wethPair.mint(player);

        address wethPairToken0 = wethPair.token0();

        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(wethPartner);

        vm.expectEmit(true, true, true, true, address(weth));
        emit Deposit(address(router), expectedSwapAmount);
        vm.expectEmit(true, true, true, true, address(weth));
        emit Transfer(address(router), address(wethPair), expectedSwapAmount);
        vm.expectEmit(true, true, true, true, address(wethPartner));
        emit Transfer(address(wethPair), player, outputAmount);
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Sync(
            wethPairToken0 == address(wethPartner)
                ? uint112(wethPartnerAmount - outputAmount)
                : uint112(ethAmount + expectedSwapAmount),
            wethPairToken0 == address(wethPartner)
                ? uint112(ethAmount + expectedSwapAmount)
                : uint112(wethPartnerAmount - outputAmount)
        );
        vm.expectEmit(true, true, true, true, address(wethPair));
        emit Swap(
            address(router),
            wethPairToken0 == address(wethPartner) ? 0 : expectedSwapAmount,
            wethPairToken0 == address(wethPartner) ? expectedSwapAmount : 0,
            wethPairToken0 == address(wethPartner) ? outputAmount : 0,
            wethPairToken0 == address(wethPartner) ? 0 : outputAmount,
            player
        );

        uint256[] memory amounts =
            router.swapETHForExactTokens{value: expectedSwapAmount}(outputAmount, path, player, MAX);

        vm.stopPrank();

        assertEq(amounts[0], expectedSwapAmount);
        assertEq(amounts[1], outputAmount);
    }

    function addLiquidity(uint256 amount0, uint256 amount1) public {
        vm.startPrank(player);
        token0.approve(address(router), MAX);
        token1.approve(address(router), MAX);

        router.addLiquidity(address(token0), address(token1), amount0, amount1, 0, 0, player, block.timestamp + 100);
        vm.stopPrank();
    }
}
