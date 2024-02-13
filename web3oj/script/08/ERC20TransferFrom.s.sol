// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/08/ERC20TransferFrom.sol";

contract ERC20TransferFromScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC20TRANSFERFROM_INSTANCE");
        address instanceOwner = vm.envAddress("ERC20TRANSFERFROM_OWNER");

        ERC20TransferFrom instance = ERC20TransferFrom(instanceAddress);

        instance.transferFrom(
            instanceOwner,
            vm.addr(privateKey),
            20 * 10 ** 18
        );

        vm.stopBroadcast();
    }
}
