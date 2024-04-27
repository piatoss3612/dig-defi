// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {TokenSender} from "../src/TokenSender.sol";
import {TokenReceiver} from "../src/TokenReceiver.sol";
import {
    CCIPLocalSimulator,
    IRouterClient,
    LinkToken,
    BurnMintERC677Helper
} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import {Test, console} from "forge-std/Test.sol";

contract TokenTransferTest is Test {
    uint256 public constant LINK_AMOUNT = 10 ether;

    CCIPLocalSimulator public ccipLocalSimulator;
    TokenSender public sender;
    TokenReceiver public receiver;

    address public requestor;

    function setUp() public {
        requestor = makeAddr("requestor");
        vm.label(requestor, "Requestor");

        ccipLocalSimulator = new CCIPLocalSimulator();
        vm.label(address(ccipLocalSimulator), "CCIP Local Simulator");

        (uint64 chainSelector, IRouterClient sourceRouter, IRouterClient destinationRouter,, LinkToken linkToken,,) =
            ccipLocalSimulator.configuration();

        sender = new TokenSender(address(sourceRouter), address(linkToken));
        vm.label(address(sender), "TokenSender");

        ccipLocalSimulator.requestLinkFromFaucet(address(sender), LINK_AMOUNT);

        receiver = new TokenReceiver(address(destinationRouter), address(linkToken));
        vm.label(address(receiver), "TokenReceiver");

        sender.setSupportedWarp(chainSelector, address(receiver));
        receiver.setSupportedWarp(chainSelector, address(sender));
    }

    function test_TransferToken() public {
        (uint64 chainSelector,,,,, BurnMintERC677Helper ccipBnM_,) = ccipLocalSimulator.configuration();
        ccipBnM_.drip(address(requestor));

        assertEq(ccipBnM_.balanceOf(address(requestor)), 1 ether);

        vm.startPrank(requestor);

        ccipBnM_.approve(address(sender), 1 ether);

        sender.sendToken(chainSelector, address(ccipBnM_), 1 ether);

        vm.stopPrank();

        assertEq(ccipBnM_.balanceOf(address(requestor)), 0);
        assertEq(ccipBnM_.balanceOf(address(receiver)), 1 ether);
    }
}
