// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../UniswapV2ERC20.sol";

contract UniswapV2ERC20WithMint is UniswapV2ERC20 {
    function mint(address to, uint256 value) public {
        _mint(to, value);
    }
}

contract ERC20 is UniswapV2ERC20WithMint {
    constructor(uint256 _totalSupply) {
        _mint(msg.sender, _totalSupply);
    }
}
