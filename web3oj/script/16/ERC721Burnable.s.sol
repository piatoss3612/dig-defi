// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/16/ERC721Burnable.sol";

contract ERC721BurnableScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC721BURNABLE_INSTANCE");

        Web3OnlineJudgeNFTBurnable instance = Web3OnlineJudgeNFTBurnable(instanceAddress);

        instance.burn(0);

        vm.stopBroadcast();
    }
}
