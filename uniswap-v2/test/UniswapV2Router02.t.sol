// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {MockWETH} from "../src/mock/MockWETH.sol";
import {DeflatingERC20} from "../src/test/DeflatingERC20.sol";
import {UniswapV2Router02} from "../src/UniswapV2Router02.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import "../src/libraries/UniswapV2Library.sol";

contract UniswapV2Router02Test is Test {
    uint256 constant MAX = type(uint256).max;
    uint256 constant INITIAL_SUPPLY = 100000 * 10 ** 18;
    uint256 constant MINIMUM_LIQUIDITY = 1000;

    Utilities utils;
    DeflatingERC20 dtt;
    DeflatingERC20 dtt2;
    MockWETH weth;
    UniswapV2Factory factory;
    UniswapV2Router02 router;
    UniswapV2Pair pair;
    UniswapV2Pair dttPair;

    uint256 playerPrivateKey;
    address player;

    function setUp() public {
        utils = new Utilities();
        vm.label(address(utils), "Utilities");

        playerPrivateKey = utils.createPrivateKey();
        player = utils.addressFromPrivateKey(playerPrivateKey);
        utils.fundUser(payable(player), 100 ether);
        vm.label(player, "Player");

        vm.startPrank(player);

        dtt = new DeflatingERC20(INITIAL_SUPPLY);
        dtt2 = new DeflatingERC20(INITIAL_SUPPLY);
        weth = new MockWETH();
        factory = new UniswapV2Factory(address(0));
        router = new UniswapV2Router02(address(factory), address(weth));
        pair = UniswapV2Pair(factory.createPair(address(dtt), address(weth)));
        dttPair = UniswapV2Pair(
            factory.createPair(address(dtt), address(dtt2))
        );

        vm.label(address(dtt), "DeflatingERC20");
        vm.label(address(dtt2), "DeflatingERC20");
        vm.label(address(weth), "MockWETH");
        vm.label(address(factory), "UniswapV2Factory");
        vm.label(address(router), "UniswapV2Router02");
        vm.label(address(pair), "UniswapV2Pair");
    }

    function test_RemoveLiquidityETHSupportingFeeOnTransferTokens() public {
        uint256 dttAmount = utils.expandTo18Decimals(1);
        uint256 wethAmount = utils.expandTo18Decimals(4);

        vm.startPrank(player);
        dtt.approve(address(router), dttAmount);

        router.addLiquidityETH{value: wethAmount}(
            address(dtt),
            dttAmount,
            dttAmount,
            wethAmount,
            player,
            MAX
        );

        uint256 dttInPair = dtt.balanceOf(address(pair));
        uint256 wethInPair = weth.balanceOf(address(pair));
        uint256 liquidity = pair.balanceOf(player);
        uint256 totalSupply = pair.totalSupply();
        uint256 naiveDttExpected = (dttInPair * liquidity) / totalSupply;
        uint256 wethExpected = (wethInPair * liquidity) / totalSupply;

        pair.approve(address(router), MAX);

        router.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(dtt),
            liquidity,
            naiveDttExpected,
            wethExpected,
            player,
            MAX
        );

        vm.stopPrank();
    }

    function test_RemoveLiquidityETHWithPermitSupportingFeeOnTransferTokens()
        public
    {
        uint256 dttAmount = (utils.expandTo18Decimals(1) * 100) / 99;
        uint256 wethAmount = utils.expandTo18Decimals(4);

        vm.startPrank(player);

        dtt.approve(address(router), dttAmount);

        router.addLiquidityETH{value: wethAmount}(
            address(dtt),
            dttAmount,
            dttAmount,
            wethAmount,
            player,
            MAX
        );

        uint256 expectedLiquidity = utils.expandTo18Decimals(2);

        uint256 nonce = pair.nonces(player);
        bytes32 digest = utils.calcDigest(
            player,
            address(router),
            expectedLiquidity - MINIMUM_LIQUIDITY,
            nonce,
            pair.DOMAIN_SEPARATOR(),
            pair.PERMIT_TYPEHASH(),
            MAX
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerPrivateKey, digest);

        uint256 dttInPair = dtt.balanceOf(address(pair));
        uint256 wethInPair = weth.balanceOf(address(pair));
        uint256 liquidity = pair.balanceOf(player);
        uint256 totalSupply = pair.totalSupply();
        uint256 naiveDttExpected = (dttInPair * liquidity) / totalSupply;
        uint256 wethExpected = (wethInPair * liquidity) / totalSupply;

        pair.approve(address(router), MAX);

        router.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
            address(dtt),
            liquidity,
            naiveDttExpected,
            wethExpected,
            player,
            MAX,
            false,
            v,
            r,
            s
        );

        vm.stopPrank();
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokensDTTToWETH()
        public
    {
        uint256 dttAmount = (utils.expandTo18Decimals(5) * 100) / 99;
        uint256 ethAmount = utils.expandTo18Decimals(10);
        uint256 amountIn = utils.expandTo18Decimals(1);

        vm.startPrank(player);

        dtt.approve(address(router), dttAmount);

        router.addLiquidityETH{value: ethAmount}(
            address(dtt),
            dttAmount,
            dttAmount,
            ethAmount,
            player,
            MAX
        );

        dtt.approve(address(router), MAX);

        address[] memory path = new address[](2);
        path[0] = address(dtt);
        path[1] = address(weth);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            0,
            path,
            player,
            MAX
        );
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokensWETHToDTT()
        public
    {
        uint256 dttAmount = (utils.expandTo18Decimals(5) * 100) / 99;
        uint256 ethAmount = utils.expandTo18Decimals(10);
        uint256 amountIn = utils.expandTo18Decimals(1);

        vm.startPrank(player);

        dtt.approve(address(router), dttAmount);

        router.addLiquidityETH{value: ethAmount}(
            address(dtt),
            dttAmount,
            dttAmount,
            ethAmount,
            player,
            MAX
        );

        weth.approve(address(router), MAX);

        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(dtt);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            0,
            path,
            player,
            MAX
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokensETHToDTT()
        public
    {
        uint256 dttAmount = (utils.expandTo18Decimals(10) * 100) / 99;
        uint256 ethAmount = utils.expandTo18Decimals(5);
        uint256 swapAmount = utils.expandTo18Decimals(1);

        vm.startPrank(player);

        dtt.approve(address(router), dttAmount);

        router.addLiquidityETH{value: ethAmount}(
            address(dtt),
            dttAmount,
            dttAmount,
            ethAmount,
            player,
            MAX
        );

        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(dtt);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: swapAmount
        }(0, path, player, MAX);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokensDTTToWETH()
        public
    {
        uint256 dttAmount = (utils.expandTo18Decimals(5) * 100) / 99;
        uint256 ethAmount = utils.expandTo18Decimals(10);
        uint256 amountIn = utils.expandTo18Decimals(1);

        vm.startPrank(player);

        dtt.approve(address(router), dttAmount);

        router.addLiquidityETH{value: ethAmount}(
            address(dtt),
            dttAmount,
            dttAmount,
            ethAmount,
            player,
            MAX
        );

        dtt.approve(address(router), MAX);

        address[] memory path = new address[](2);
        path[0] = address(dtt);
        path[1] = address(weth);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn,
            0,
            path,
            player,
            MAX
        );
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokensDTTToDTT()
        public
    {
        uint256 dttAmount = (utils.expandTo18Decimals(5) * 100) / 99;
        uint256 dtt2Amount = utils.expandTo18Decimals(5);
        uint256 amountIn = utils.expandTo18Decimals(1);

        vm.startPrank(player);

        dtt.approve(address(router), dttAmount);

        router.addLiquidity(
            address(dtt),
            address(dtt2),
            dttAmount,
            dtt2Amount,
            0,
            0,
            player,
            MAX
        );

        dtt.approve(address(router), MAX);

        address[] memory path = new address[](2);
        path[0] = address(dtt);
        path[1] = address(dtt2);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn,
            0,
            path,
            player,
            MAX
        );
    }
}
