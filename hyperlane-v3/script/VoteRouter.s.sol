// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VoteRouter} from "../src/VoteRouter.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        VoteRouter instance = new VoteRouter(
            0x2d1889fe5B092CD988972261434F7E5f26041115,
            11155111,
            0xC5FdAfa7D8aD01156852e3E6403459358C21EA62
        );

        console.log("VoteRouter created at address: ", address(instance));

        vm.stopBroadcast();
    }
}

contract VoteScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        VoteRouter instance = VoteRouter(
            0x1490c98b64Dc2a5963B2648a195ACE9719225d5D
        );

        instance.sendVote{value: 1000 gwei}(
            106343027174924039072363677969788076485983697713036371895217183766366697150692,
            VoteRouter.Vote.AGAINST
        );

        vm.stopBroadcast();
    }
}
