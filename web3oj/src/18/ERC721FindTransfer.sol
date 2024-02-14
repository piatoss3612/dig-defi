// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Web3OnlineJudgeNFTFind is ERC721 {
    constructor(address _player, uint256 tokenId) ERC721("Web3 Online Judge NFT", "WEB3OJNFT") {
        _safeMint(_player, tokenId);
    }
}