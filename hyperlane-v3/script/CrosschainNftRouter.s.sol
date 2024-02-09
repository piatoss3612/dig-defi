// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {CrosschainNftRouter} from "../src/CrosschainNftRouter.sol";

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
            0xE06F728cB5fD5a45BA12a7528e5f90d4641B85EF
        );

        uint32 domainId = 80001;

        instance.setDomainToNftContract(
            domainId,
            0x4a1A6865A5bb6C9ed988052e6f004c81c9D424Eb
        );

        string
            memory uri = "https://green-main-hoverfly-930.mypinata.cloud/ipfs/QmXbFt5tDifdSgPmhFrwD56iNsJqbxCZ8dSdv4qzp49PNs";

        uint256 fee = instance.estimateFee(domainId, vm.addr(privateKey), uri);

        instance.sendNft{value: fee}(domainId, vm.addr(privateKey), uri);

        console.log("Sent NFT to domain: ", domainId);

        vm.stopBroadcast();
    }
}
// contract VoteScript is Script {
//     function setUp() public {}

//     function run() public {
//         uint256 privateKey = vm.envUint("PRIVATE_KEY");

//         vm.startBroadcast(privateKey);

//         VoteRouter instance = VoteRouter(
//             0x1490c98b64Dc2a5963B2648a195ACE9719225d5D
//         );

//         instance.sendVote{value: 1000 gwei}(
//             106343027174924039072363677969788076485983697713036371895217183766366697150692,
//             VoteRouter.Vote.AGAINST
//         );

//         vm.stopBroadcast();
//     }
// }
