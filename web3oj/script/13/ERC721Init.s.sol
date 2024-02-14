// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/13/ERC721Init.sol";

contract ERC721InitScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC721INIT_INSTANCE");

        ERC721Init instance = ERC721Init(instanceAddress);

        MyERC721 token = new MyERC721();

        instance.setWeb3ojNFT(address(token));
       
        vm.stopBroadcast();
    }
}
