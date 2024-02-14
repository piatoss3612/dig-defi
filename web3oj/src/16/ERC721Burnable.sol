// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract Web3OnlineJudgeNFTBurnable is ERC721, ERC721Burnable {
    constructor(address _player) ERC721("Web3 Online Judge NFT", "WEB3OJNFT") {
        _safeMint(_player, 0);
    }
}