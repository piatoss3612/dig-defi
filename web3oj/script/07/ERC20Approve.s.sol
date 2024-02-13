// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/07/ERC20Approve.sol";

contract ERC20ApproveScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC20APPROVE_INSTANCE");

        ERC20Approve instance = ERC20Approve(instanceAddress);

        MyERC20 web3ojt = new MyERC20();

        web3ojt.approve(instanceAddress, 20 * 10 ** web3ojt.decimals());

        instance.setWeb3ojt(address(web3ojt));

        vm.stopBroadcast();
    }
}
