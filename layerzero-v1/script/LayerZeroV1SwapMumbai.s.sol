// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/LayerZeroV1Swap.sol";
import "forge-std/Test.sol";

contract DeployScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        new LayerZeroV1Swap(0xf69186dfBa60DdB133E91E9A4B5673624293d8F8);

        vm.stopBroadcast();
    }
}

contract SetupScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        LayerZeroV1Swap instance = LayerZeroV1Swap(
            payable(0xc76a9033e2B46c8305417A0f065C9f77b5D04fAb)
        );

        instance.trustAddress(0x4e15C6Ba57e4bFaF200867F84Bdd7E6bb77EaC39);

        vm.stopBroadcast();
    }
}

contract CheckBalanceScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address contractAddress = 0xc76a9033e2B46c8305417A0f065C9f77b5D04fAb;
        address sender = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        uint256 contractBalance = contractAddress.balance;
        uint256 senderBalance = sender.balance;

        console.log("Contract Balance: ", contractBalance);
        console.log("Sender Balance: ", senderBalance);

        vm.stopBroadcast();
    }
}

contract EstimateGasScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        LayerZeroV1Swap instance = LayerZeroV1Swap(
            payable(0xc76a9033e2B46c8305417A0f065C9f77b5D04fAb)
        );

        (uint estimatedGas, ) = instance.estimateFees(
            bytes(""),
            0x656640299E8e4c3EADCb7c9C89F013DCE9312B33,
            1 ether
        );

        console.log("Estimated gas: ", estimatedGas);

        vm.stopBroadcast();
    }
}

contract SwapScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        LayerZeroV1Swap instance = LayerZeroV1Swap(
            payable(0xc76a9033e2B46c8305417A0f065C9f77b5D04fAb)
        );

        (uint estimatedGas, ) = instance.estimateFees(
            bytes(""),
            0x656640299E8e4c3EADCb7c9C89F013DCE9312B33,
            1 ether
        );

        instance.swapToETH{value: 1 ether + estimatedGas}(
            0x656640299E8e4c3EADCb7c9C89F013DCE9312B33,
            1 ether
        );

        vm.stopBroadcast();
    }
}

contract WithdrawScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address payable contractAddress = payable(
            0xc76a9033e2B46c8305417A0f065C9f77b5D04fAb
        );

        vm.startBroadcast(privateKey);

        LayerZeroV1Swap instance = LayerZeroV1Swap(contractAddress);

        instance.withdrawAll();

        vm.stopBroadcast();
    }
}
