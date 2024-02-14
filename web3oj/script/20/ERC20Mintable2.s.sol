// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/20/ERC721Mintable2.sol";

contract ERC721Mintable2Script is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC721MINTABLE2_INSTANCE");
        address instanceOwner = vm.envAddress("ERC721MINTABLE2_OWNER");

        ERC721Mintable2 instance = ERC721Mintable2(instanceAddress);

        MyERC721 token = new MyERC721(instanceOwner);

        instance.setToken(address(token));

        vm.stopBroadcast();
    }
}
