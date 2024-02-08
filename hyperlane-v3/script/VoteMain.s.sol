// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VoteMain} from "../src/VoteMain.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        VoteMain instance = new VoteMain(
            0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766
        );

        console.log("VoteMain created at address: ", address(instance));

        vm.stopBroadcast();
    }
}

contract CreateProposalScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        VoteMain instance = VoteMain(
            0xC5FdAfa7D8aD01156852e3E6403459358C21EA62
        );

        uint256 proposalId = instance.createProposal(
            "Interoperability with Mumbai",
            "We should create a bridge to Mumbai to allow for cross-chain transactions.",
            100000000000
        );

        console.log("Proposal created with ID: ", proposalId);

        vm.stopBroadcast();
    }
}

contract CheckProposalScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        VoteMain instance = VoteMain(
            0xC5FdAfa7D8aD01156852e3E6403459358C21EA62
        );

        (, uint agaist) = instance.getVotes(
            106343027174924039072363677969788076485983697713036371895217183766366697150692
        );

        console.log("Votes against: ", agaist);

        vm.stopBroadcast();
    }
}
