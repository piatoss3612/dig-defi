// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/06/ERC20Transfer.sol";

contract ERC20TransferScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC20TRANSFER_INSTANCE");

        ERC20Transfer instance = ERC20Transfer(instanceAddress);

        MyERC20 web3ojt = new MyERC20();

        web3ojt.transfer(instanceAddress, 20 * 10 ** web3ojt.decimals());

        instance.setWeb3ojt(address(web3ojt));

        vm.stopBroadcast();
    }
}
