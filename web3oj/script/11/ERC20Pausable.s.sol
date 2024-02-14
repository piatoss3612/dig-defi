// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/11/ERC20Pausable.sol";

contract ERC20PausableScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC20PAUSABLE_INSTANCE");

        Web3OJTPausable instance = Web3OJTPausable(instanceAddress);

        instance.pause();

        vm.stopBroadcast();
    }
}
