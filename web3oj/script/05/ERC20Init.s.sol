// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/05/ERC20Init.sol";

contract ERC20InitScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC20INIT_INSTANCE");

        ERC20Init instance = ERC20Init(instanceAddress);

        MyERC20 web3ojt = new MyERC20();

        instance.setWeb3ojt(address(web3ojt));

        vm.stopBroadcast();
    }
}
