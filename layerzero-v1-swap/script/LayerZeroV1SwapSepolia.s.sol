// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/LayerZeroV1Swap.sol";
import "forge-std/Test.sol";

contract DeployScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        new LayerZeroV1Swap(0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1);

        vm.stopBroadcast();
    }
}

contract SetupScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address payable contractAddress = payable(
            0x4e15C6Ba57e4bFaF200867F84Bdd7E6bb77EaC39
        );

        vm.startBroadcast(privateKey);

        LayerZeroV1Swap instance = LayerZeroV1Swap(contractAddress);

        instance.trustAddress(0xc76a9033e2B46c8305417A0f065C9f77b5D04fAb);

        bool ok = contractAddress.send(1 ether);
        require(ok, "send 1 ether failed");

        vm.stopBroadcast();
    }
}

contract CheckBalanceScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address contractAddress = 0x4e15C6Ba57e4bFaF200867F84Bdd7E6bb77EaC39;
        address receiver = 0x656640299E8e4c3EADCb7c9C89F013DCE9312B33;

        vm.startBroadcast(privateKey);

        uint256 contractBalance = contractAddress.balance;
        uint256 receiverBalance = receiver.balance;

        console.log("Contract Balance: ", contractBalance);
        console.log("Receiver Balance: ", receiverBalance);

        vm.stopBroadcast();
    }
}

contract WithdrawScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address payable contractAddress = payable(
            0x4e15C6Ba57e4bFaF200867F84Bdd7E6bb77EaC39
        );

        vm.startBroadcast(privateKey);

        LayerZeroV1Swap instance = LayerZeroV1Swap(contractAddress);

        instance.withdrawAll();

        vm.stopBroadcast();
    }
}
