// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {UniswapV2ERC20WithMint} from "../src/test/ERC20.sol";
import "forge-std/Test.sol";

contract UniswapV2ERC20Test is Test {
    UniswapV2ERC20WithMint public token;

    uint256 ownerPrivateKey;
    uint256 spenderPrivateKey;

    address owner;
    address spender;

    function setUp() public {
        token = new UniswapV2ERC20WithMint();

        ownerPrivateKey = 0x1234567890123456789012345678901234567890123456789012345678901234;
        owner = vm.addr(ownerPrivateKey);

        spenderPrivateKey = 0x1234567890123456789012345678901234567890123456789012345678904321;
        spender = vm.addr(spenderPrivateKey);

        token.mint(owner, 1e18);
    }

    function test_Permit() public {
        bytes32 digest = calcDigest(
            owner,
            spender,
            1e9,
            token.nonces(owner),
            1 days
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(owner, spender, 1e9, 1 days, v, r, s);

        assertEq(token.allowance(owner, spender), 1e9);
        assertEq(token.nonces(owner), 1);
    }

    function test_PermitAndTransferFrom() public {
        bytes32 digest = calcDigest(
            owner,
            spender,
            1e9,
            token.nonces(owner),
            1 days
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(owner, spender, 1e9, 1 days, v, r, s);

        assertEq(token.balanceOf(owner), 1e18);
        assertEq(token.balanceOf(spender), 0);

        vm.prank(spender);

        token.transferFrom(owner, spender, 1e9);

        assertEq(token.balanceOf(spender), 1e9);
    }

    function testRevert_ExpiredPermit() public {
        bytes32 digest = calcDigest(
            owner,
            spender,
            1e9,
            token.nonces(owner),
            1 days
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.warp(1 days + 1 seconds);

        vm.expectRevert("UniswapV2: EXPIRED");

        token.permit(owner, spender, 1e9, 1 days, v, r, s);
    }

    function testRevert_InvalidNonce() public {
        bytes32 digest = calcDigest(
            owner,
            spender,
            1e9,
            token.nonces(owner) + 1,
            1 days
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.expectRevert("UniswapV2: INVALID_SIGNATURE");

        token.permit(owner, spender, 1e9, 1 days, v, r, s);
    }

    function testRevert_SignatureReplay() public {
        bytes32 digest = calcDigest(
            owner,
            spender,
            1e9,
            token.nonces(owner),
            1 days
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(owner, spender, 1e9, 1 days, v, r, s);

        vm.expectRevert("UniswapV2: INVALID_SIGNATURE");

        token.permit(owner, spender, 1e9, 1 days, v, r, s);
    }

    function calcDigest(
        address _owner,
        address _spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            token.PERMIT_TYPEHASH(),
                            _owner,
                            _spender,
                            value,
                            nonce,
                            deadline
                        )
                    )
                )
            );
    }
}
