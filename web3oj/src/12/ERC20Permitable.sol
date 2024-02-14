// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Web3OJTPermitable is ERC20, ERC20Permit {
    constructor()
        ERC20("Web3 Online Judge Token", "WEB3OJT")
        ERC20Permit("Web3 Online Judge Token")
    {
        _mint(msg.sender, 2000000000 * 10 ** decimals());
    }
}