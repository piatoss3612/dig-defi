// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import {SimpleDAO} from "../src/SimpleDAO.sol";
import {GovToken} from "../src/GovToken.sol";
import {Timelock} from "../src/Timelock.sol";
import {Box} from "../src/Box.sol";

contract SimpleDAOTest is Test {
    error OwnableUnauthorizedAccount(address account);

    SimpleDAO dao;
    GovToken token;
    Timelock timelock;
    Box box;

    uint256 public constant MIN_DELAY = 3600; // 1 hour - after a vote passes, you have 1 hour before you can enact
    uint256 public constant QUORUM_PERCENTAGE = 4; // Need 4% of voters to pass
    uint256 public constant VOTING_PERIOD = 50400; // This is how long voting lasts
    uint256 public constant VOTING_DELAY = 1; // How many blocks till a proposal vote becomes active

    address[] proposers;
    address[] executors;

    address public constant VOTER = address(1);
    uint256 public constant VOTER_INITIAL_BALANCE = 100 ether;

    function setUp() public {
        token = new GovToken();
        token.mint(VOTER, VOTER_INITIAL_BALANCE);

        vm.prank(VOTER);
        token.delegate(VOTER);

        timelock = new Timelock(MIN_DELAY, proposers, executors);
        dao = new SimpleDAO(token, timelock);
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(dao));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, address(this));

        box = new Box();
        box.transferOwnership(address(timelock));
    }

    function test_RevertUpdateBoxWithoutGovernance() public {
        vm.expectRevert(abi.encodePacked(OwnableUnauthorizedAccount.selector, abi.encode(address(this))));
        box.store(1);
    }

    function test_GovernanceUpdatesBox() public {
        // 1. Propose
        uint256 valueToStore = 777;
        string memory description = "Store 777 in the box";
        bytes memory encodedFuncCall = abi.encodeWithSignature("store(uint256)", valueToStore);

        address[] memory addressesToCall = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory functionCalls = new bytes[](1);

        addressesToCall[0] = address(box);
        values[0] = 0;
        functionCalls[0] = encodedFuncCall;

        uint256 proposalId = dao.propose(addressesToCall, values, functionCalls, description);

        console.log("Proposal ID:", proposalId);
        console.log("Proposal State:", uint256(dao.state(proposalId)) == 0 ? "Pending" : "Active");

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        console.log("Proposal State:", uint256(dao.state(proposalId)) == 0 ? "Pending" : "Active");

        // 2. Vote
        string memory reason = "I like the number 777";
        uint8 voteWay = 1;
        vm.prank(VOTER);
        dao.castVoteWithReason(proposalId, voteWay, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD / 13 + 1);

        console.log("Proposal State:", uint256(dao.state(proposalId)) == 4 ? "Succeeded" : "Failed");

        // 3. Queue
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        dao.queue(addressesToCall, values, functionCalls, descriptionHash);

        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);

        // 4. Execute
        dao.execute(addressesToCall, values, functionCalls, descriptionHash);

        console.log("Box Value:", box.retrieve());
        assertEq(box.retrieve(), valueToStore);
    }
}
