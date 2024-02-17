// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "../ERC20A.sol";

contract TestERC20A is ERC20A {
    constructor(string memory name_, string memory symbol_) ERC20A(name_, symbol_) {
        address msgSender;
        assembly {
            msgSender := caller()
        }

        _mint(msgSender, 1000000 * 10 ** 18);
    }

    function mint(address account, uint256 amount) public  {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public  {
        _burn(account, amount);
    }

    function transfer(address from, address to, uint256 amount) public  {
        _transfer(from, to, amount);
    }

    function approve(address owner, address spender, uint256 amount) public  {
        _approve(owner, spender, amount);
    }
}