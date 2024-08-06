// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {LokiToken} from "src/LokiToken.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop airdrop;
    LokiToken token;

    bytes32 merkleRoot = 0xd83f4a7eed75e3d20922784ea7c1801033b28025f98b7074724e5e7cb17879d6;
    uint256 amountToCollect = 25 * 1e18;
    bytes32 proofOne = 0xf1d540e0e4e8e89bd0478477c77dda2d30f0636e91f8081899dfd69b172cafa7;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proofOne, proofTwo];

    address user;
    uint256 userPrivKey;

    function setUp() public {
        token = new LokiToken();
        airdrop = new MerkleAirdrop(merkleRoot, token);
        token.mint(address(airdrop), amountToCollect);

        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);

        vm.prank(user);
        airdrop.claim(user, amountToCollect, proof);

        uint256 endingBalance = token.balanceOf(user);

        assertEq(endingBalance, startingBalance + amountToCollect);
    }
}
