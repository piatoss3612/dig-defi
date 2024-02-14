// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IERC721Mintable2 {
    function mint(address to) external;
}

contract ERC721Mintable2{
    IERC721Mintable2 public token;

    function setToken(address _token) public {
        token = IERC721Mintable2(_token);
    }
}

contract MyERC721 is ERC721, IERC721Mintable2 {
    address public minter;
    uint256 public tokenId;

    modifier onlyMinter() {
        require(_msgSender() == minter, "MyERC721: caller is not the minter");
        _;
    }

    constructor(address _minter) ERC721("MyERC721", "MYE") {
        minter = _minter;
    }

    function mint(address to) external onlyMinter {
        uint256 _tokenId = tokenId++; // 최초로 mint된 토큰의 tokenId가 0인지 검사하는 코드가 있으므로, tokenId를 나중에 증가시킴
        _mint(to, _tokenId);
    }
}