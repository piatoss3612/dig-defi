// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/31/DormantAccount.sol";

contract DormantAccountScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("DORMANTACCOUNT_INSTANCE");

        new Injection{value: 100 wei}(payable(instanceAddress));

        console.log("DormantAccount balance: ", instanceAddress.balance);
       
        vm.stopBroadcast();
    }
}
