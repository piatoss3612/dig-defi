// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import {TestERC20A} from "../src/test/TestERC20A.sol";
import {ERC20A, IERC20, IERC20Errors} from "../src/ERC20A.sol";

contract ERC20ATest is Test {
    TestERC20A token;

    uint256 holderPrivateKey;
    address holder;

    uint256 recipientPrivateKey;
    address recipient;

    function setUp() public {
        holderPrivateKey = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
        holder = vm.addr(holderPrivateKey);

        recipientPrivateKey = 0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890;
        recipient = vm.addr(recipientPrivateKey);

        vm.prank(holder);
        token = new TestERC20A("MyToken", "MTK");
    }

    function test_Constructor() public {
        string memory name = "MyToken2";
        string memory symbol = "MTK2";

        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(address(0), holder, 1000000 * 10 ** 18);

        vm.prank(holder);
        TestERC20A newToken = new TestERC20A(name, symbol);

        assertEq(newToken.name(), name);
        assertEq(newToken.symbol(), symbol);
        assertEq(newToken.decimals(), 18);
        assertEq(newToken.totalSupply(), 1000000 * 10 ** 18);
        assertEq(newToken.balanceOf(holder), 1000000 * 10 ** 18);
    }

    function test_RevertConstructorWithTooLongName() public {
        vm.expectRevert(ERC20A.StringLengthOver31.selector);

        new ERC20A("MyTokenDSFADFSDFSDFADFSDAFASDFASDFASDFASDFSDFDFSD", "MTK");
    }

    function test_RevertConstructorWithTooLongSymbol() public {
        vm.expectRevert(ERC20A.StringLengthOver31.selector);

        new ERC20A("MyToken", "MTKDSFADFSDFSDFADFSDAFASDFASDFASDFASDFSDFDFSD");
    }

    function test_Name() public {
        string memory name = token.name();

        assertEq(name, "MyToken");
    }

    function test_Symbol() public {
        string memory symbol = token.symbol();

        assertEq(symbol, "MTK");
    }

    function test_Decimals() public {
        uint8 decimals = token.decimals();

        assertEq(decimals, 18);
    }

    function test_TotalSupply() public {
        uint256 totalSupply = token.totalSupply();

        assertEq(totalSupply, 1000000 * 10 ** 18);
    }

    function test_BalanceOf() public {
        uint256 balance = token.balanceOf(holder);

        assertEq(balance, 1000000 * 10 ** 18);
    }

    function test_Allowance() public {
        uint256 allowance = token.allowance(holder, recipient);

        assertEq(allowance, 0);
    }

    function test_Mint() public {
        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(address(0), recipient, 1000000 * 10 ** 18);

        vm.prank(holder);
        token.mint(recipient, 1000000 * 10 ** 18);

        uint256 balance = token.balanceOf(recipient);

        assertEq(balance, 1000000 * 10 ** 18);

        uint256 totalSupply = token.totalSupply();

        assertEq(totalSupply, 2000000 * 10 ** 18);
    }

    function test_RevertMintWithArithmeticOverflow() public {
        vm.expectRevert(ERC20A.ArithmeticOverflow.selector);

        vm.prank(holder);
        token.mint(recipient, 2**256 - 1);
    }

    function test_RevertMintWithERC20InvalidReceiver() public {
        vm.expectRevert(abi.encodePacked(IERC20Errors.ERC20InvalidReceiver.selector, abi.encode(address(0))));

        vm.prank(holder);
        token.mint(address(0), 1000000 * 10 ** 18);
    }

    function test_Burn() public {
        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(holder, address(0), 1000000 * 10 ** 18);

        vm.prank(holder);
        token.burn(holder, 1000000 * 10 ** 18);

        uint256 balance = token.balanceOf(holder);

        assertEq(balance, 0);

        uint256 totalSupply = token.totalSupply();

        assertEq(totalSupply, 0);
    }

    function test_RevertBurnWithERC20InvalidSender() public {
        vm.expectRevert(abi.encodePacked(IERC20Errors.ERC20InvalidSender.selector, abi.encode(address(0))));

        vm.prank(holder);
        token.burn(address(0), 1000000 * 10 ** 18);
    }

    function test_RevertBurnWithERC20InsufficientBalance() public {
        uint256 balance = token.balanceOf(holder);
        uint256 amount = balance + 1;

        vm.expectRevert(abi.encodePacked(IERC20Errors.ERC20InsufficientBalance.selector, abi.encode(holder, balance, amount)));

        vm.prank(holder);
        token.burn(holder, amount);
    }

    function test_Transfer() public {
        uint256 balance = token.balanceOf(holder);
        uint256 amount = balance / 2;

        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(holder, recipient, amount);

        vm.prank(holder);
        token.transfer(recipient, amount);

        uint256 updatedBalance = token.balanceOf(holder);

        assertEq(updatedBalance, balance - amount);

        uint256 recipientBalance = token.balanceOf(recipient);

        assertEq(recipientBalance, amount);
    }

    function test_RevertTransferWithInvalidSender() public {
        vm.expectRevert(abi.encodePacked(IERC20Errors.ERC20InvalidSender.selector, abi.encode(address(0))));

        vm.prank(holder);
        token.transfer(address(0), recipient, 1000000 * 10 ** 18);
    }

    function test_RevertTransferWithERC20InvalidReceiver() public {
        vm.expectRevert(abi.encodePacked(IERC20Errors.ERC20InvalidReceiver.selector, abi.encode(address(0))));

        vm.prank(holder);
        token.transfer(holder, address(0), 1000000 * 10 ** 18);
    }

    function test_RevertTransferWithERC20InsufficientBalance() public {
        uint256 balance = token.balanceOf(holder);
        uint256 amount = balance + 1;

        vm.expectRevert(abi.encodePacked(IERC20Errors.ERC20InsufficientBalance.selector, abi.encode(holder, balance, amount)));

        vm.prank(holder);
        token.transfer(recipient, amount);
    }

    function test_Approve() public {
        uint256 allowance = token.allowance(holder, recipient);

        assertEq(allowance, 0);

        vm.expectEmit(true, true, true, true);
        emit IERC20.Approval(holder, recipient, 1000000 * 10 ** 18);

        vm.prank(holder);
        token.approve(recipient, 1000000 * 10 ** 18);

        uint256 updatedAllowance = token.allowance(holder, recipient);

        assertEq(updatedAllowance, 1000000 * 10 ** 18);
    }

    function test_RevertApproveWithERC20InvalidApprover() public {
        vm.expectRevert(abi.encodePacked(IERC20Errors.ERC20InvalidApprover.selector, abi.encode(address(0))));

        vm.prank(holder);
        token.approve(address(0), recipient, 1000000 * 10 ** 18);
    }

    function test_RevertApproveWithERC20InvalidSpender() public {
        vm.expectRevert(abi.encodePacked(IERC20Errors.ERC20InvalidSpender.selector, abi.encode(address(0))));

        vm.prank(holder);
        token.approve(address(0), 1000000 * 10 ** 18);
    }

    function test_TransferFrom() public {
        uint256 balance = token.balanceOf(holder);
        uint256 amount = balance / 2;

        vm.expectEmit(true, true, true, true);
        emit IERC20.Approval(holder, recipient, amount);

        vm.prank(holder);
        token.approve(recipient, amount);

        uint256 updatedAllowance = token.allowance(holder, recipient);

        assertEq(updatedAllowance, amount);

        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(holder, recipient, amount);

        vm.prank(recipient);
        token.transferFrom(holder, recipient, amount);

        uint256 updatedBalance = token.balanceOf(holder);

        assertEq(updatedBalance, balance - amount);

        uint256 recipientBalance = token.balanceOf(recipient);

        assertEq(recipientBalance, amount);

        uint256 updatedAllowance2 = token.allowance(holder, recipient);

        assertEq(updatedAllowance2, 0);
    }

    function test_TransferWithMaxAllowance() public {
        uint256 balance = token.balanceOf(holder);
        uint256 amount = balance / 2;
        uint256 max = type(uint256).max;

        vm.expectEmit(true, true, true, true);
        emit IERC20.Approval(holder, recipient, max);

        vm.prank(holder);
        token.approve(recipient, max);

        uint256 updatedAllowance = token.allowance(holder, recipient);

        assertEq(updatedAllowance, max);

        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(holder, recipient, amount);

        vm.prank(recipient);
        token.transferFrom(holder, recipient, amount);

        uint256 updatedBalance = token.balanceOf(holder);

        assertEq(updatedBalance, balance - amount);

        uint256 recipientBalance = token.balanceOf(recipient);

        assertEq(recipientBalance, amount);

        uint256 updatedAllowance2 = token.allowance(holder, recipient);

        assertEq(updatedAllowance2, max);
    }

    function test_RevertTransferFromWithInsufficientAllowance() public {
        uint256 balance = token.balanceOf(holder);
        uint256 amount = balance / 2;

        vm.expectRevert(abi.encodePacked(IERC20Errors.ERC20InsufficientAllowance.selector, abi.encode(holder, 0, amount)));

        vm.prank(holder);
        token.transferFrom(holder, recipient, amount);
    }
}