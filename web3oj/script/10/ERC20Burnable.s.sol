// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/10/ERC20Burnable.sol";

contract ERC20BurnableScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC20BURNABLE_INSTANCE");

        ERC20Burnable instance = ERC20Burnable(instanceAddress);

        instance.burn(20 * 10 ** instance.decimals());

        vm.stopBroadcast();
    }
}
