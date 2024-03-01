// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../src/interfaces/IUniswapV2Factory.sol";
import "../src/UniswapV2Factory.sol";
import "../src/UniswapV2Pair.sol";
import "forge-std/Test.sol";

contract UniswapV2FatoryTest is Test {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    UniswapV2Factory public factory;

    address feeToSetter;

    function setUp() public {
        feeToSetter = vm.addr(0x1234567890123456789012345678901234567890123456789012345678901234);

        factory = new UniswapV2Factory(feeToSetter);
    }

    function test_Getter() public {
        assertEq(factory.feeToSetter(), feeToSetter);
        assertEq(factory.feeTo(), address(0));
        assertEq(factory.allPairsLength(), 0);
    }

    function test_CreatePair() public {
        address tokenA = vm.addr(1);
        address tokenB = vm.addr(2);

        (address token0, address token1) = sortToken(tokenA, tokenB);

        address expect = computePairAddress(address(factory), token0, token1);

        vm.expectEmit(true, true, true, true, address(factory));
        emit PairCreated(token0, token1, expect, 1);

        address pair = factory.createPair(token0, token1);

        assertEq(pair, expect);
        assertEq(factory.getPair(token0, token1), pair);
        assertEq(factory.getPair(token1, token0), pair);
        assertEq(factory.allPairsLength(), 1);
        assertEq(factory.allPairs(0), pair);

        UniswapV2Pair pairContract = UniswapV2Pair(pair);

        assertEq(pairContract.factory(), address(factory));
        assertEq(pairContract.token0(), token0);
        assertEq(pairContract.token1(), token1);
    }

    function testRevert_CreatePairWithIdenticalAddresses() public {
        address tokenA = vm.addr(1);
        address tokenB = vm.addr(1);

        vm.expectRevert("UniswapV2: IDENTICAL_ADDRESSES");
        factory.createPair(tokenA, tokenB);
    }

    function testRevert_CreatePairWithZeroAddress() public {
        address tokenA = address(0);
        address tokenB = vm.addr(2);

        vm.expectRevert("UniswapV2: ZERO_ADDRESS");
        factory.createPair(tokenA, tokenB);
    }

    function testRevert_CreatePairWithPairexists() public {
        address tokenA = vm.addr(1);
        address tokenB = vm.addr(2);

        factory.createPair(tokenA, tokenB);

        vm.expectRevert("UniswapV2: PAIR_EXISTS");
        factory.createPair(tokenA, tokenB);
    }

    function test_SetFeeTo() public {
        address feeTo = vm.addr(1);

        vm.prank(feeToSetter);
        factory.setFeeTo(feeTo);

        assertEq(factory.feeTo(), feeTo);
    }

    function testRevert_SetFeeToWithFoobidden() public {
        address feeTo = vm.addr(1);

        vm.expectRevert("UniswapV2: FORBIDDEN");

        factory.setFeeTo(feeTo);
    }

    function test_SetFeeToSetter() public {
        address newFeeToSetter = vm.addr(2);

        vm.prank(feeToSetter);
        factory.setFeeToSetter(newFeeToSetter);

        assertEq(factory.feeToSetter(), newFeeToSetter);
    }

    function testRevert_SetFeeToSetterWithFoobidden() public {
        address newFeeToSetter = vm.addr(2);

        vm.expectRevert("UniswapV2: FORBIDDEN");

        factory.setFeeToSetter(newFeeToSetter);
    }

    function test_ComputePairAddress() public {
        address tokenA = vm.addr(1);
        address tokenB = vm.addr(2);

        (address token0, address token1) = sortToken(tokenA, tokenB);

        address p1 = computePairAddress(address(factory), token0, token1);
        address p2 = computePairAddressInAssembly(address(factory), token0, token1);

        assertEq(p1, p2);
    }

    function sortToken(address tokenA, address tokenB) public pure returns (address token0, address token1) {
        if (tokenA < tokenB) {
            token0 = tokenA;
            token1 = tokenB;
        } else {
            token0 = tokenB;
            token1 = tokenA;
        }
    }

    function computePairAddress(address _factory, address tokenA, address tokenB) public pure returns (address pair) {
        (address token0, address token1) = sortToken(tokenA, tokenB);
        bytes32 byteCodeHash = keccak256(type(UniswapV2Pair).creationCode);
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        return address(uint160(uint256(keccak256(abi.encodePacked(hex"ff", _factory, salt, byteCodeHash)))));
    }

    function computePairAddressInAssembly(address _factory, address tokenA, address tokenB)
        public
        pure
        returns (address pair)
    {
        (address token0, address token1) = sortToken(tokenA, tokenB);
        bytes32 byteCodeHash = keccak256(type(UniswapV2Pair).creationCode);
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));

        assembly {
            let ptr := mload(0x40)

            mstore(add(ptr, 0x40), byteCodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, _factory)

            let start := add(ptr, 0x0b)

            mstore8(start, 0xff)

            pair := keccak256(start, 85)
        }
    }
}
