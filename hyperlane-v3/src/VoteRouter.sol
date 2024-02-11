// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IMailbox} from "@hyperlane-v3/contracts/interfaces/IMailbox.sol";

contract VoteRouter {
    enum Vote {
        FOR,
        AGAINST
    } // Creating enums to denote two types of vote

    // variables to store important contract addresses and domain identifiers
    address mailbox;
    uint32 domainId;
    address voteContract;

    constructor(address _mailbox, uint32 _domainId, address _voteContract) {
        mailbox = _mailbox;
        domainId = _domainId;
        voteContract = _voteContract;
    }

    // By calling this function you can cast your vote on other chain
    function sendVote(uint256 _proposalId, Vote _voteType) external payable {
        uint256 quote = IMailbox(mailbox).quoteDispatch(
            domainId,
            addressToBytes32(voteContract),
            abi.encode(_proposalId, msg.sender, _voteType)
        );
        IMailbox(mailbox).dispatch{value: quote}(
            domainId,
            addressToBytes32(voteContract),
            abi.encode(_proposalId, msg.sender, _voteType)
        );
    }

    // converts address to bytes32
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
