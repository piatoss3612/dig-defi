// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/19/ERC721Mintable.sol";

contract ERC721MintableScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC721MINTABLE_INSTANCE");
        address instanceOwner = vm.envAddress("ERC721MINTABLE_OWNER");

        ERC721Mintable instance = ERC721Mintable(instanceAddress);

        MyERC721 token = new MyERC721(instanceOwner);

        instance.setToken(address(token));

        vm.stopBroadcast();
    }
}
