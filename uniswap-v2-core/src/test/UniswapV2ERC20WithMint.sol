// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../UniswapV2ERC20.sol";

contract UniswapV2ERC20WithMint is UniswapV2ERC20 {
    function mint(address to, uint256 value) public {
        _mint(to, value);
    }
}
