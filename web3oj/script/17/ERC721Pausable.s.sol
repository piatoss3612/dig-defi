// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/17/ERC721Pausable.sol";

contract ERC721PausableScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC721PAUSABLE_INSTANCE");

        Web3OnlineJudgeNFTPausable instance = Web3OnlineJudgeNFTPausable(instanceAddress);

        instance.pause();

        vm.stopBroadcast();
    }
}
