// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {GreetingSender} from "../src/GreetingSender.sol";
import {GreetingReceiver} from "../src/GreetingReceiver.sol";
import {CCIPLocalSimulator, IRouterClient, LinkToken} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import {Test, console} from "forge-std/Test.sol";

contract GreetingTest is Test {
    uint256 public constant LINK_AMOUNT = 10 ether;

    CCIPLocalSimulator public ccipLocalSimulator;
    GreetingSender public sender;
    GreetingReceiver public receiver;

    function setUp() public {
        ccipLocalSimulator = new CCIPLocalSimulator();
        vm.label(address(ccipLocalSimulator), "CCIP Local Simulator");

        (uint64 chainSelector, IRouterClient sourceRouter, IRouterClient destinationRouter,, LinkToken linkToken,,) =
            ccipLocalSimulator.configuration();

        sender = new GreetingSender(address(sourceRouter), address(linkToken));
        vm.label(address(sender), "GreetingSender");

        ccipLocalSimulator.requestLinkFromFaucet(address(sender), LINK_AMOUNT);

        receiver = new GreetingReceiver(address(destinationRouter), address(linkToken));
        vm.label(address(receiver), "GreetingReceiver");

        sender.setSupportedWarp(chainSelector, address(receiver));
        receiver.setSupportedWarp(chainSelector, address(sender));
    }

    function test_SendGreeting() public {
        (uint64 chainSelector,,,,,,) = ccipLocalSimulator.configuration();
        string memory message = "Hello, World!";

        sender.sendGreeting(chainSelector, message);

        string memory received = receiver.messages(0);

        assertEq(received, message);
    }
}
