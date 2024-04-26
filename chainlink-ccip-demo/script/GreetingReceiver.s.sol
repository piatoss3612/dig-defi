// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {GreetingReceiver} from "../src/GreetingReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {LinkTokenInterface} from "@chainlink/contracts/v0.8/interfaces/LinkTokenInterface.sol";
import {Script, console} from "forge-std/Script.sol";
import {Helper} from "./Helper.sol";

contract GreetingReceiverScript is Script, Helper {
    function setUp() public {}

    function run() public {
        vm.broadcast();
    }

    function deploy(SupportedNetworks network, bool chargeFee) public {
        vm.startBroadcast();
        (address router, address linkToken,,) = getConfigFromNetwork(network);

        GreetingReceiver receiver = new GreetingReceiver(router, linkToken);

        if (chargeFee) {
            bool ok = IERC20(linkToken).transfer(address(receiver), 1 ether);
            if (!ok) {
                revert("transfer failed");
            }
            console.log("Transfered 1 LINK to GreetingSender");
        }

        console.log("GreetingReceiver deployed at", address(receiver));

        vm.stopBroadcast();
    }

    function setSender(address payable receiver, address sender, SupportedNetworks senderNetwork) public {
        vm.startBroadcast();

        (,,, uint64 chainId) = getConfigFromNetwork(senderNetwork);

        GreetingReceiver(receiver).setSupportedWarp(chainId, sender);

        console.log("GreetingSender set to", GreetingReceiver(payable(receiver)).getSupportedWarp(chainId));
    }

    function readMessage(address payable receiver, uint256 messageId) public {
        vm.startBroadcast();

        string memory message = GreetingReceiver(receiver).messages(messageId);

        console.log("Message", messageId, ":", message);
    }
}
