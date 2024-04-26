// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {GreetingSender} from "../src/GreetingSender.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {LinkTokenInterface} from "@chainlink/contracts/v0.8/interfaces/LinkTokenInterface.sol";
import {Script, console} from "forge-std/Script.sol";
import {Helper} from "./Helper.sol";

contract GreetingSenderScript is Script, Helper {
    function setUp() public {}

    function run() public {
        vm.broadcast();
    }

    function deploy(SupportedNetworks network, bool _chargeFee) public {
        vm.startBroadcast();
        (address router, address linkToken,,) = getConfigFromNetwork(network);

        GreetingSender sender = new GreetingSender(router, linkToken);

        if (_chargeFee) {
            bool ok = IERC20(linkToken).transfer(address(sender), 1 ether);
            if (!ok) {
                revert("transfer failed");
            }
            console.log("Transfered 1 LINK to GreetingSender");
        }

        console.log("GreetingSender deployed at", address(sender));

        vm.stopBroadcast();
    }

    function setSender(address sender, address receiver, SupportedNetworks receiverNetwork) public {
        vm.startBroadcast();

        (,,, uint64 chainId) = getConfigFromNetwork(receiverNetwork);

        GreetingSender(payable(sender)).setSupportedWarp(chainId, receiver);

        console.log("GreetingReceiver set to", GreetingSender(payable(sender)).getSupportedWarp(chainId));
    }

    function sendGreeting(address sender, string memory message, SupportedNetworks receiverNetwork) public {
        vm.startBroadcast();

        (,,, uint64 chainId) = getConfigFromNetwork(receiverNetwork);

        GreetingSender(payable(sender)).sendGreeting(chainId, message);

        console.log("GreetingSender sent message to", GreetingSender(payable(sender)).getSupportedWarp(chainId));

        vm.stopBroadcast();
    }

    function chargeFee(address sender, SupportedNetworks network) public {
        vm.startBroadcast();

        (, address linkToken,,) = getConfigFromNetwork(network);

        bool ok = IERC20(linkToken).transfer(address(sender), 2 ether);
        if (!ok) {
            revert("transfer failed");
        }
        console.log("Transfered 1 LINK to GreetingSender");

        vm.stopBroadcast();
    }
}
