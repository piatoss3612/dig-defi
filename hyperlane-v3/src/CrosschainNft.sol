// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IMessageRecipient} from "@hyperlane-v3/contracts/interfaces/IMessageRecipient.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721, ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract CrosschainNft is ERC721URIStorage, IMessageRecipient {
    address public mailbox;
    uint256 public tokenId;

    error NotMailbox();

    event Minted(address indexed to, uint256 indexed tokenId, string tokenURI);

    modifier onlyMailbox() {
        if (msg.sender != mailbox) {
            revert NotMailbox();
        }
        _;
    }

    constructor(address _mailbox) ERC721("CrosschainNft", "CCNFT") {
        mailbox = _mailbox;
    }

    function handle(
        uint32 /*_origin*/,
        bytes32 /*_sender*/,
        bytes memory _body
    ) external payable onlyMailbox {
        (address to, string memory tokenURI) = abi.decode(
            _body,
            (address, string)
        );

        uint256 _tokenId = ++tokenId;

        _mint(to, _tokenId);
        _setTokenURI(_tokenId, tokenURI);

        emit Minted(to, _tokenId, tokenURI);
    }
}
