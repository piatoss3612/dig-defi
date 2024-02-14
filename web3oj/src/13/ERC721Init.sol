// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Init{
    ERC721 public web3ojNFT;

    function setWeb3ojNFT(address _web3ojNFT) public {
        web3ojNFT = ERC721(_web3ojNFT);
    }
}

contract MyERC721 is ERC721 {
    constructor() ERC721("Web3 Online Judge NFT", "WEB3OJNFT") {
        _mint(msg.sender, 0);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://app.web3oj.com/web3ojnft/";
    }
}