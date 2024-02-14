// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/25/Lock.sol";

contract LockScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("LOCK_INSTANCE");

        LockProblem instance = LockProblem(instanceAddress);

        Unlock solver = new Unlock();

        solver.unlock(instanceAddress);

        console.log("Locked?", instance.lock());

        vm.stopBroadcast();
    }
}
