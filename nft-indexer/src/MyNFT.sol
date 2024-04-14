//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 _nextTokenId;

    constructor() ERC721("MyNFT", "MNFT") {}

    function testMint() public {
        for (uint256 i = 0; i < 10; i++) {
            _mint(msg.sender);
        }
    }

    function _mint(address to) internal {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }
}
