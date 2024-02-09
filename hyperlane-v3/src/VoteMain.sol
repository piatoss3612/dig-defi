// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IMailbox} from "@hyperlane/contracts/interfaces/IMailbox.sol";
import {IPostDispatchHook} from "@hyperlane/contracts/interfaces/hooks/IPostDispatchHook.sol";

contract VoteMain {
    event ProposalCreated(
        uint256 indexed _proposalId,
        string _title,
        string _description,
        uint256 _createdTimestamp,
        uint256 _votingPeriod
    );

    event VoteCasted(
        uint256 indexed _proposalId,
        address indexed voter,
        Vote _voteType
    );

    enum Vote {
        FOR,
        AGAINST
    }

    struct Proposal {
        string title;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 createdTimestamp;
        uint256 votingPeriod;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public votes;

    address public mailbox;

    constructor(address _mailbox) {
        mailbox = _mailbox;
    }

    modifier onlyMailbox() {
        require(msg.sender == mailbox, "Only mailbox can call this function.");
        _;
    }

    function createProposal(
        string memory _title,
        string memory _description,
        uint256 _votingPeriod
    ) external returns (uint256 proposalId) {
        proposalId = uint256(
            keccak256(abi.encodePacked(_title, _description, _votingPeriod))
        );

        require(
            proposals[proposalId].createdTimestamp == 0,
            "Proposal already exists."
        );

        proposals[proposalId] = Proposal({
            title: _title,
            description: _description,
            forVotes: 0,
            againstVotes: 0,
            createdTimestamp: block.timestamp,
            votingPeriod: _votingPeriod
        });

        emit ProposalCreated(
            proposalId,
            _title,
            _description,
            block.timestamp,
            _votingPeriod
        );
    }

    function _vote(
        uint256 _proposalId,
        address _voter,
        Vote _voteType
    ) internal {
        require(
            proposals[_proposalId].createdTimestamp != 0,
            "Proposal doesn't exist."
        );
        require(
            proposals[_proposalId].createdTimestamp +
                proposals[_proposalId].votingPeriod >=
                block.timestamp,
            "Voting period already ended."
        );
        require(!votes[_voter][_proposalId], "Voter already voted.");
        if (_voteType == Vote.FOR) {
            proposals[_proposalId].forVotes += 1;
        } else if (_voteType == Vote.AGAINST) {
            proposals[_proposalId].againstVotes += 1;
        }
        votes[_voter][_proposalId] = true;
        emit VoteCasted(_proposalId, _voter, _voteType);
    }

    function voteProposal(uint256 _proposalId, Vote _voteType) external {
        _vote(_proposalId, msg.sender, _voteType);
    }

    function handle(
        uint32 /*_origin*/,
        bytes32 /*_sender*/,
        bytes memory _body
    ) external onlyMailbox {
        (uint256 _proposalId, address _voter, Vote _voteType) = abi.decode(
            _body,
            (uint256, address, Vote)
        );
        _vote(_proposalId, _voter, _voteType);
    }

    function getVotes(
        uint256 _proposalId
    ) external view returns (uint256 _for, uint256 _against) {
        _for = proposals[_proposalId].forVotes;
        _against = proposals[_proposalId].againstVotes;
    }
}
