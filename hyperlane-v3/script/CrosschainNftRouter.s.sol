// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {CrosschainNftRouter} from "../src/CrosschainNftRouter.sol";
import {TypeCasts} from "@hyperlane-v3/contracts/libs/TypeCasts.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        CrosschainNftRouter instance = new CrosschainNftRouter(
            0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766
        );

        console.log("Deployed CrosschainNftRouter at: ", address(instance));

        vm.stopBroadcast();
    }
}

contract SendNFT is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        CrosschainNftRouter instance = CrosschainNftRouter(
            0xe996557C3A4D3586786359ccCaBe9f76842D1783
        );

        uint32 domainId = 80001;
        bytes32 recipientAddress = TypeCasts.addressToBytes32(
            0x3716B00671B801f34bB4c99Aba5889A13d65c42E
        );

        instance.enrollRemoteRouter(domainId, recipientAddress);

        string
            memory uri = "https://green-main-hoverfly-930.mypinata.cloud/ipfs/QmXbFt5tDifdSgPmhFrwD56iNsJqbxCZ8dSdv4qzp49PNs";

        uint256 fee = instance.estimateFee(domainId, vm.addr(privateKey), uri);

        console.log("Estimated fee: ", fee);

        instance.sendNft{value: fee}(domainId, vm.addr(privateKey), uri);

        console.log("Sent NFT to domain: ", domainId);

        vm.stopBroadcast();
    }
}
