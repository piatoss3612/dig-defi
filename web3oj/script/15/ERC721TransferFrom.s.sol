// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ERC721TransferFromScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC721TRANSFERFROM_INSTANCE");

        IERC721 instance = IERC721(instanceAddress);

        address owner = instance.ownerOf(0);

        instance.transferFrom(owner, vm.addr(privateKey), 0);

        owner = instance.ownerOf(0);

        console.log("owner: ", owner);
       
        vm.stopBroadcast();
    }
}
