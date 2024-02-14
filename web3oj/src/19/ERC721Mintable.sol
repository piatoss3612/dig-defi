// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IERC721Mintable {
    function mint(address to, uint256 tokenId) external;
}

contract ERC721Mintable{
    IERC721Mintable public token;

    function setToken(address _token) public {
        token = IERC721Mintable(_token);
    }
}

contract MyERC721 is ERC721, IERC721Mintable {
    address public minter;

    modifier onlyMinter() {
        require(_msgSender() == minter, "MyERC721: caller is not the minter");
        _;
    }

    constructor(address _minter) ERC721("MyERC721", "MYE") {
        minter = _minter;
    }

    function mint(address to, uint256 tokenId) public onlyMinter {
        _safeMint(to, tokenId);
    }
}