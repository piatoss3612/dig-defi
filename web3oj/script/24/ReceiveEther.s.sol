// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/24/ReceiveEther.sol";

contract ReceiveEtherScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("RECEIVE_ETHER_INSTANCE");

        ReceiveEtherFunctionProblem instance = ReceiveEtherFunctionProblem(instanceAddress);

        bool ok = payable(instanceAddress).send(1000 wei);
        require(ok, "send failed");

        ReceiveEther solver = new ReceiveEther();

        instance.setReceiveEtherAddress(payable(address(solver)));

        vm.stopBroadcast();
    }
}
