// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {MockToken2} from "../src/mock/MockToken.sol";
import {MockWETH} from "../src/mock/MockWETH.sol";
import {DeflatingERC20} from "../src/test/DeflatingERC20.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import {UniswapV2Router02} from "../src/UniswapV2Router02.sol";

contract FuzzTest is Test {
    uint256 public constant MAX = type(uint256).max;
    uint256 public constant MAX_AMOUNT = type(uint112).max;

    // utils
    Utilities utils;

    // tokens
    MockToken2 public usdc;
    MockToken2 public usdt;
    DeflatingERC20 feeToken;
    MockWETH weth;

    // pairs
    UniswapV2Pair stablePair;
    UniswapV2Pair wethPair;
    UniswapV2Pair feePair;
    UniswapV2Pair feeWethPair;

    // factory
    UniswapV2Factory factory;

    // router
    UniswapV2Router02 router;

    // deployer
    address public deployer;

    // player
    uint256 public playerPrivateKey;
    address public player;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        deployer = users[0];
        vm.label(deployer, "Deployer");

        playerPrivateKey = utils.createPrivateKey();
        player = utils.addressFromPrivateKey(playerPrivateKey);
        vm.label(player, "Player");

        vm.startPrank(deployer);

        // create tokens
        usdc = new MockToken2("USDC", "USDC", 18);
        vm.label(address(usdc), "USDC");

        usdt = new MockToken2("USDT", "USDT", 6);
        vm.label(address(usdt), "USDT");

        feeToken = new DeflatingERC20(0);
        vm.label(address(feeToken), "FeeToken");

        weth = new MockWETH();
        vm.label(address(weth), "WETH");

        // create factory and pairs
        factory = new UniswapV2Factory(address(deployer));
        vm.label(address(factory), "Factory");

        stablePair = UniswapV2Pair(factory.createPair(address(usdc), address(usdt)));
        vm.label(address(stablePair), "StablePair");

        wethPair = UniswapV2Pair(factory.createPair(address(usdc), address(weth)));
        vm.label(address(wethPair), "WETHPair");

        feePair = UniswapV2Pair(factory.createPair(address(usdc), address(feeToken)));
        vm.label(address(feePair), "FeePair");

        feeWethPair = UniswapV2Pair(factory.createPair(address(feeToken), address(weth)));
        vm.label(address(feeWethPair), "FeeWETHPair");

        // create router
        router = new UniswapV2Router02(address(factory), address(weth));
        vm.label(address(router), "Router");

        vm.stopPrank();
    }

    function testFuzz_StablePair_AddLiquidity(uint256 amount1, uint256 amount2) public {
        uint256 amountA = _between(amount1, 10 ** 3 + 1, MAX_AMOUNT);
        uint256 amountB = _between(amount2, 10 ** 3 + 1, MAX_AMOUNT);

        vm.startPrank(deployer);
        usdc.mint(player, amountA);
        usdt.mint(player, amountB);
        vm.stopPrank();

        (uint256 amountABefore, uint256 amountBBefore,) = stablePair.getReserves();
        uint256 totalSupplyBefore = stablePair.totalSupply();
        uint256 playerBalanceBefore = stablePair.balanceOf(player);
        uint256 kBefore = amountABefore * amountBBefore;

        vm.startPrank(player);

        usdc.approve(address(router), MAX);
        usdt.approve(address(router), MAX);

        router.addLiquidity(address(usdc), address(usdt), amountA, amountB, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountAAfter, uint256 amountBAfter,) = stablePair.getReserves();
        uint256 totalSupplyAfter = stablePair.totalSupply();
        uint256 playerBalanceAfter = stablePair.balanceOf(player);
        uint256 kAfter = amountAAfter * amountBAfter;

        assertGt(amountAAfter, amountABefore, "Reserve A should be greater than the previous reserve A");
        assertGt(amountBAfter, amountBBefore, "Reserve B should be greater than the previous reserve B");
        assertGt(totalSupplyAfter, totalSupplyBefore, "Total supply should be greater than the previous total supply");
        assertGt(
            playerBalanceAfter, playerBalanceBefore, "Player balance should be greater than the previous player balance"
        );
        assertGt(kAfter, kBefore, "K should be greater than the previous K");
    }

    function testFuzz_WETHPair_AddLiquidityETH(uint256 amount1, uint256 amount2) public {
        uint256 amountA = _between(amount1, 10 ** 3 + 1, MAX_AMOUNT);
        uint256 amountB = _between(amount2, 10 ** 3 + 1, MAX_AMOUNT);

        vm.startPrank(deployer);
        usdc.mint(player, amountA);
        vm.deal(player, amountB);
        vm.stopPrank();

        (uint256 amountABefore, uint256 amountBBefore,) = wethPair.getReserves();
        uint256 totalSupplyBefore = wethPair.totalSupply();
        uint256 playerBalanceBefore = wethPair.balanceOf(player);
        uint256 kBefore = amountABefore * amountBBefore;

        vm.startPrank(player);

        usdc.approve(address(router), MAX);

        router.addLiquidityETH{value: amountB}(address(usdc), amountA, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountAAfter, uint256 amountBAfter,) = wethPair.getReserves();
        uint256 totalSupplyAfter = wethPair.totalSupply();
        uint256 playerBalanceAfter = wethPair.balanceOf(player);
        uint256 kAfter = amountAAfter * amountBAfter;

        assertGt(amountAAfter, amountABefore, "Reserve A should be greater than the previous reserve A");
        assertGt(amountBAfter, amountBBefore, "Reserve B should be greater than the previous reserve B");
        assertGt(totalSupplyAfter, totalSupplyBefore, "Total supply should be greater than the previous total supply");
        assertGt(
            playerBalanceAfter, playerBalanceBefore, "Player balance should be greater than the previous player balance"
        );
        assertGt(kAfter, kBefore, "K should be greater than the previous K");
    }

    function testFuzz_StablePair_RemoveLiquidity(uint256 amount1, uint256 amount2) public {
        uint256 amountA = _between(amount1, 10 ** 3 + 1, MAX_AMOUNT);
        uint256 amountB = _between(amount2, 10 ** 3 + 1, MAX_AMOUNT);

        vm.startPrank(deployer);
        usdc.mint(player, amountA);
        usdt.mint(player, amountB);
        vm.stopPrank();

        vm.startPrank(player);

        usdc.approve(address(router), MAX);
        usdt.approve(address(router), MAX);

        (,, uint256 liquidity) = router.addLiquidity(address(usdc), address(usdt), amountA, amountB, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountABefore, uint256 amountBBefore,) = stablePair.getReserves();
        uint256 totalSupplyBefore = stablePair.totalSupply();
        uint256 playerBalanceBefore = stablePair.balanceOf(player);
        uint256 kBefore = amountABefore * amountBBefore;

        vm.startPrank(player);

        stablePair.approve(address(router), MAX);

        router.removeLiquidity(address(usdc), address(usdt), liquidity, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountAAfter, uint256 amountBAfter,) = stablePair.getReserves();
        uint256 totalSupplyAfter = stablePair.totalSupply();
        uint256 playerBalanceAfter = stablePair.balanceOf(player);
        uint256 kAfter = amountAAfter * amountBAfter;

        assertLt(amountAAfter, amountABefore, "Reserve A should be less than the previous reserve A");
        assertLt(amountBAfter, amountBBefore, "Reserve B should be less than the previous reserve B");
        assertLt(totalSupplyAfter, totalSupplyBefore, "Total supply should be less than the previous total supply");
        assertLt(
            playerBalanceAfter, playerBalanceBefore, "Player balance should be less than the previous player balance"
        );
        assertLt(kAfter, kBefore, "K should be less than the previous K");
    }

    function testFuzz_WETHPair_RemoveLiquidityETH(uint256 amount1, uint256 amount2) public {
        uint256 amountA = _between(amount1, 10 ** 3 + 1, MAX_AMOUNT);
        uint256 amountB = _between(amount2, 10 ** 3 + 1, MAX_AMOUNT);

        vm.startPrank(deployer);
        usdc.mint(player, amountA);
        vm.deal(player, amountB);
        vm.stopPrank();

        vm.startPrank(player);

        usdc.approve(address(router), MAX);

        (,, uint256 liquidity) = router.addLiquidityETH{value: amountB}(address(usdc), amountA, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountABefore, uint256 amountBBefore,) = wethPair.getReserves();
        uint256 totalSupplyBefore = wethPair.totalSupply();
        uint256 playerBalanceBefore = wethPair.balanceOf(player);
        uint256 kBefore = amountABefore * amountBBefore;

        vm.startPrank(player);

        wethPair.approve(address(router), MAX);

        router.removeLiquidityETH(address(usdc), liquidity, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountAAfter, uint256 amountBAfter,) = wethPair.getReserves();
        uint256 totalSupplyAfter = wethPair.totalSupply();
        uint256 playerBalanceAfter = wethPair.balanceOf(player);
        uint256 kAfter = amountAAfter * amountBAfter;

        assertLt(amountAAfter, amountABefore, "Reserve A should be less than the previous reserve A");
        assertLt(amountBAfter, amountBBefore, "Reserve B should be less than the previous reserve B");
        assertLt(totalSupplyAfter, totalSupplyBefore, "Total supply should be less than the previous total supply");
        assertLt(
            playerBalanceAfter, playerBalanceBefore, "Player balance should be less than the previous player balance"
        );
        assertLt(kAfter, kBefore, "K should be less than the previous K");
    }

    function testFuzz_StablePair_RemoveLiquidityWithPermit(uint256 amount1, uint256 amount2, bool approveMax) public {
        uint256 amountA = _between(amount1, 10 ** 3 + 1, MAX_AMOUNT);
        uint256 amountB = _between(amount2, 10 ** 3 + 1, MAX_AMOUNT);

        vm.startPrank(deployer);
        usdc.mint(player, amountA);
        usdt.mint(player, amountB);
        vm.stopPrank();

        vm.startPrank(player);

        usdc.approve(address(router), MAX);
        usdt.approve(address(router), MAX);

        (,, uint256 liquidity) = router.addLiquidity(address(usdc), address(usdt), amountA, amountB, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountABefore, uint256 amountBBefore,) = stablePair.getReserves();
        uint256 totalSupplyBefore = stablePair.totalSupply();
        uint256 playerBalanceBefore = stablePair.balanceOf(player);
        uint256 kBefore = amountABefore * amountBBefore;

        vm.startPrank(player);

        bytes32 digest;

        if (approveMax) {
            digest = utils.calcDigest(
                player,
                address(router),
                MAX,
                stablePair.nonces(player),
                stablePair.DOMAIN_SEPARATOR(),
                stablePair.PERMIT_TYPEHASH(),
                MAX
            );
        } else {
            digest = utils.calcDigest(
                player,
                address(router),
                liquidity,
                stablePair.nonces(player),
                stablePair.DOMAIN_SEPARATOR(),
                stablePair.PERMIT_TYPEHASH(),
                MAX
            );
        }

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerPrivateKey, digest);

        router.removeLiquidityWithPermit(
            address(usdc), address(usdt), liquidity, 0, 0, player, MAX, approveMax, v, r, s
        );

        vm.stopPrank();

        (uint256 amountAAfter, uint256 amountBAfter,) = stablePair.getReserves();
        uint256 totalSupplyAfter = stablePair.totalSupply();
        uint256 playerBalanceAfter = stablePair.balanceOf(player);
        uint256 kAfter = amountAAfter * amountBAfter;

        assertLt(amountAAfter, amountABefore, "Reserve A should be less than the previous reserve A");
        assertLt(amountBAfter, amountBBefore, "Reserve B should be less than the previous reserve B");
        assertLt(totalSupplyAfter, totalSupplyBefore, "Total supply should be less than the previous total supply");
        assertLt(
            playerBalanceAfter, playerBalanceBefore, "Player balance should be less than the previous player balance"
        );
        assertLt(kAfter, kBefore, "K should be less than the previous K");
    }

    function testFuzz_WETHPair_RemoveLiquidityETHWithPermit(uint256 amount1, uint256 amount2, bool approveMax) public {
        uint256 amountA = _between(amount1, 10 ** 3 + 1, MAX_AMOUNT);
        uint256 amountB = _between(amount2, 10 ** 3 + 1, MAX_AMOUNT);

        vm.startPrank(deployer);
        usdc.mint(player, amountA);
        vm.deal(player, amountB);
        vm.stopPrank();

        vm.startPrank(player);

        usdc.approve(address(router), MAX);

        (,, uint256 liquidity) = router.addLiquidityETH{value: amountB}(address(usdc), amountA, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountABefore, uint256 amountBBefore,) = wethPair.getReserves();
        uint256 totalSupplyBefore = wethPair.totalSupply();
        uint256 playerBalanceBefore = wethPair.balanceOf(player);
        uint256 kBefore = amountABefore * amountBBefore;

        vm.startPrank(player);

        bytes32 digest;

        if (approveMax) {
            digest = utils.calcDigest(
                player,
                address(router),
                MAX,
                wethPair.nonces(player),
                wethPair.DOMAIN_SEPARATOR(),
                wethPair.PERMIT_TYPEHASH(),
                MAX
            );
        } else {
            digest = utils.calcDigest(
                player,
                address(router),
                liquidity,
                wethPair.nonces(player),
                wethPair.DOMAIN_SEPARATOR(),
                wethPair.PERMIT_TYPEHASH(),
                MAX
            );
        }

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerPrivateKey, digest);

        router.removeLiquidityETHWithPermit(address(usdc), liquidity, 0, 0, player, MAX, approveMax, v, r, s);

        vm.stopPrank();

        (uint256 amountAAfter, uint256 amountBAfter,) = wethPair.getReserves();
        uint256 totalSupplyAfter = wethPair.totalSupply();
        uint256 playerBalanceAfter = wethPair.balanceOf(player);
        uint256 kAfter = amountAAfter * amountBAfter;

        assertLt(amountAAfter, amountABefore, "Reserve A should be less than the previous reserve A");
        assertLt(amountBAfter, amountBBefore, "Reserve B should be less than the previous reserve B");
        assertLt(totalSupplyAfter, totalSupplyBefore, "Total supply should be less than the previous total supply");
        assertLt(
            playerBalanceAfter, playerBalanceBefore, "Player balance should be less than the previous player balance"
        );
        assertLt(kAfter, kBefore, "K should be less than the previous K");
    }

    function testFuzz_FeeWETHPair_RemoveLiquidityETHSupportingFeeOnTransferTokens(uint256 amount1, uint256 amount2)
        public
    {
        uint256 amountA = _between(amount1, (10 ** 3) + 1, MAX_AMOUNT);
        uint256 amountB = _between(amount2, 10 ** 3 + 1, MAX_AMOUNT);

        amountA += amountA / 100; // 1% fee

        vm.startPrank(deployer);
        feeToken.mint(player, amountA);
        vm.deal(player, amountB);
        vm.stopPrank();

        vm.startPrank(player);

        feeToken.approve(address(router), MAX);

        (,, uint256 liquidity) = router.addLiquidityETH{value: amountB}(address(feeToken), amountA, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountABefore, uint256 amountBBefore,) = feeWethPair.getReserves();
        uint256 totalSupplyBefore = feeWethPair.totalSupply();
        uint256 playerBalanceBefore = feeWethPair.balanceOf(player);
        uint256 kBefore = amountABefore * amountBBefore;

        vm.startPrank(player);

        feeWethPair.approve(address(router), MAX);

        router.removeLiquidityETHSupportingFeeOnTransferTokens(address(feeToken), liquidity, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountAAfter, uint256 amountBAfter,) = feeWethPair.getReserves();
        uint256 totalSupplyAfter = feeWethPair.totalSupply();
        uint256 playerBalanceAfter = feeWethPair.balanceOf(player);
        uint256 kAfter = amountAAfter * amountBAfter;

        assertLt(amountAAfter, amountABefore, "Reserve A should be less than the previous reserve A");
        assertLt(amountBAfter, amountBBefore, "Reserve B should be less than the previous reserve B");
        assertLt(totalSupplyAfter, totalSupplyBefore, "Total supply should be less than the previous total supply");
        assertLt(
            playerBalanceAfter, playerBalanceBefore, "Player balance should be less than the previous player balance"
        );
        assertLt(kAfter, kBefore, "K should be less than the previous K");
    }

    function testFuzz_FeeWETHPair_RemoveLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        uint256 amount1, uint256 amount2, bool approveMax
    ) public {
        uint256 amountA = _between(amount1, (10 ** 3) + 1, MAX_AMOUNT);
        uint256 amountB = _between(amount2, 10 ** 3 + 1, MAX_AMOUNT);

        amountA += amountA / 100; // 1% fee

        vm.startPrank(deployer);
        feeToken.mint(player, amountA);
        vm.deal(player, amountB);
        vm.stopPrank();

        vm.startPrank(player);

        feeToken.approve(address(router), MAX);

        (,, uint256 liquidity) = router.addLiquidityETH{value: amountB}(address(feeToken), amountA, 0, 0, player, MAX);

        vm.stopPrank();

        (uint256 amountABefore, uint256 amountBBefore,) = feeWethPair.getReserves();
        uint256 totalSupplyBefore = feeWethPair.totalSupply();
        uint256 playerBalanceBefore = feeWethPair.balanceOf(player);
        uint256 kBefore = amountABefore * amountBBefore;

        vm.startPrank(player);

        bytes32 digest;

        if (approveMax) {
            digest = utils.calcDigest(
                player,
                address(router),
                MAX,
                feeWethPair.nonces(player),
                feeWethPair.DOMAIN_SEPARATOR(),
                feeWethPair.PERMIT_TYPEHASH(),
                MAX
            );
        } else {
            digest = utils.calcDigest(
                player,
                address(router),
                liquidity,
                feeWethPair.nonces(player),
                feeWethPair.DOMAIN_SEPARATOR(),
                feeWethPair.PERMIT_TYPEHASH(),
                MAX
            );
        }

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerPrivateKey, digest);

        router.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
            address(feeToken), liquidity, 0, 0, player, MAX, approveMax, v, r, s
        );

        vm.stopPrank();

        (uint256 amountAAfter, uint256 amountBAfter,) = feeWethPair.getReserves();
        uint256 totalSupplyAfter = feeWethPair.totalSupply();
        uint256 playerBalanceAfter = feeWethPair.balanceOf(player);
        uint256 kAfter = amountAAfter * amountBAfter;

        assertLt(amountAAfter, amountABefore, "Reserve A should be less than the previous reserve A");
        assertLt(amountBAfter, amountBBefore, "Reserve B should be less than the previous reserve B");
        assertLt(totalSupplyAfter, totalSupplyBefore, "Total supply should be less than the previous total supply");
        assertLt(
            playerBalanceAfter, playerBalanceBefore, "Player balance should be less than the previous player balance"
        );
        assertLt(kAfter, kBefore, "K should be less than the previous K");
    }

    function testFuzz_StablePair_SwapExactTokensForTokens(uint256 amount) public {
        uint amountIn = _between(amount, 1, MAX_AMOUNT);

        (uint256 reserveABefore, uint256 reserveBBefore, ) = stablePair.getReserves();
        uint256 kBefore = reserveABefore * reserveBBefore;

        vm.startPrank(deployer);

        usdc.mint(address(stablePair), 100000);
        usdt.mint(address(stablePair), 100000);   
        stablePair.sync();
        
        usdc.mint(player, amountIn);
        usdt.mint(player, amountIn);   

        vm.stopPrank();
        
        address[] memory path = new address[](2);
        path[0] = address(usdc);
        path[1] = address(usdt);

        uint playerBalanceABefore = usdc.balanceOf(player);
        uint playerBalanceBBefore = usdt.balanceOf(player);

        vm.startPrank(player);

        usdc.approve(address(router), MAX);

        try router.swapExactTokensForTokens(amountIn, 0, path, player, MAX) {
            uint playerBalanceAAfter = usdc.balanceOf(player);
            uint playerBalanceBAfter = usdt.balanceOf(player);
            (uint256 reserveAAfter, uint256 reserveBAfter, ) = stablePair.getReserves();
            uint256 kAfter = reserveAAfter * reserveBAfter;
            
            assertGe(kAfter, kBefore, "K should be greater than the previous K");

            address token0 = stablePair.token0();

            if (token0 == address(usdc)) {
                assertLt(playerBalanceAAfter, playerBalanceABefore, "Player balance A should be less than the previous player balance A");
                assertGt(playerBalanceBAfter, playerBalanceBBefore, "Player balance B should be greater than the previous player balance B");
            } else {
                assertGt(playerBalanceAAfter, playerBalanceABefore, "Player balance A should be greater than the previous player balance A");
                assertLt(playerBalanceBAfter, playerBalanceBBefore, "Player balance B should be less than the previous player balance B");
            }
        } catch {
            // overflow
            return;
        }
    }

    function testFuzz_WETHPair_SwapExactETHForTokens(uint amount) public {
        uint amountIn = _between(amount, 1, 100000000000000);

        (uint256 reserveABefore, uint256 reserveBBefore, ) = wethPair.getReserves();
        uint256 kBefore = reserveABefore * reserveBBefore;

        vm.startPrank(deployer);
        vm.deal(deployer, 100 ether);
        usdc.mint(address(wethPair), 100000000000000);
        weth.deposit{value: 100 ether}();
        weth.transfer(address(wethPair), 100 ether);
        wethPair.sync();
        
        usdc.mint(player, amountIn);

        vm.stopPrank();
        
        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(usdc);

        uint playerBalanceABefore = amountIn;
        uint playerBalanceBBefore = usdc.balanceOf(player);

        vm.startPrank(player);
        vm.deal(player, amountIn);

        try router.swapExactETHForTokens{value: amountIn}(0, path, player, MAX) {
            address token0 = wethPair.token0();
            (uint playerBalanceAAfter, uint playerBalanceBAfter) = token0 == address(weth) ? (weth.balanceOf(player), usdc.balanceOf(player)) : (usdc.balanceOf(player), weth.balanceOf(player));
            (uint256 reserveAAfter, uint256 reserveBAfter, ) = wethPair.getReserves();
            uint256 kAfter = reserveAAfter * reserveBAfter;
            
            assertGe(kAfter, kBefore, "K should be greater than the previous K");

            if (token0 == address(weth)) {
                assertLt(playerBalanceAAfter, playerBalanceABefore, "Player balance A should be less than the previous player balance A");
                assertGt(playerBalanceBAfter, playerBalanceBBefore, "Player balance B should be greater than the previous player balance B");
            } else {
                assertGt(playerBalanceAAfter, playerBalanceABefore, "Player balance A should be greater than the previous player balance A");
                assertLt(playerBalanceBAfter, playerBalanceBBefore, "Player balance B should be less than the previous player balance B");
            }
        } catch {
            // overflow
            // insufficient output amount
            return;
        }

        vm.stopPrank();
    }

    function testFuzz_WETHPair_SwapTokensForExactETH(uint amount) public {
        uint amountOut = _between(amount, 1, 100 ether);

        (uint256 reserveABefore, uint256 reserveBBefore, ) = wethPair.getReserves();
        uint256 kBefore = reserveABefore * reserveBBefore;

        vm.startPrank(deployer);
        vm.deal(deployer, 100 ether);
        usdc.mint(address(wethPair), 100000000000000);
        weth.deposit{value: 100 ether}();
        weth.transfer(address(wethPair), 100 ether);
        wethPair.sync();
        
        usdc.mint(player, amountOut);

        vm.stopPrank();
        
        address[] memory path = new address[](2);
        path[0] = address(usdc);
        path[1] = address(weth);

        uint playerBalanceABefore = usdc.balanceOf(player);
        uint playerBalanceBBefore = 0;

        vm.startPrank(player);

        usdc.approve(address(router), MAX);

        try router.swapTokensForExactETH(amountOut, 0, path, player, MAX) {
            address token0 = wethPair.token0();
            (uint playerBalanceAAfter, uint playerBalanceBAfter) = token0 == address(usdc) ? (usdc.balanceOf(player), weth.balanceOf(player)) : (weth.balanceOf(player), usdc.balanceOf(player));
            (uint256 reserveAAfter, uint256 reserveBAfter, ) = wethPair.getReserves();
            uint256 kAfter = reserveAAfter * reserveBAfter;
            
            assertGe(kAfter, kBefore, "K should be greater than the previous K");

            if (token0 == address(usdc)) {
                assertLt(playerBalanceAAfter, playerBalanceABefore, "Player balance A should be less than the previous player balance A");
                assertGt(playerBalanceBAfter, playerBalanceBBefore, "Player balance B should be greater than the previous player balance B");
            } else {
                assertGt(playerBalanceAAfter, playerBalanceABefore, "Player balance A should be greater than the previous player balance A");
                assertLt(playerBalanceBAfter, playerBalanceBBefore, "Player balance B should be less than the previous player balance B");
            }
        } catch {
            // overflow
            // insufficient output amount
            return;
        }

        vm.stopPrank();
    }

    // Bounding function similar to vm.assume but is more efficient regardless of the fuzzying framework
    // This is also a guarante bound of the input unlike vm.assume which can only be used for narrow checks
    function _between(uint256 random, uint256 low, uint256 high) public pure returns (uint256) {
        return low + random % (high - low);
    }
}
