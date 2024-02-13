// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/09/ERC20Mintable.sol";

contract ERC20MintableScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC20MINTABLE_INSTANCE");
        address instanceOwner = vm.envAddress("ERC20MINTABLE_OWNER");

        ERC20Mintable instance = ERC20Mintable(instanceAddress);

        MyERC20 web3ojt = new MyERC20(instanceOwner);

        instance.setToken(address(web3ojt));

        vm.stopBroadcast();
    }
}
