// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract ERC20BurnableToken is ERC20, ERC20Burnable {
    constructor(address _player) ERC20("BurnableToken", "BTK") {
        _mint(msg.sender, 2000000000 * 10 ** decimals());
        transfer(_player, 20 * 10 ** decimals());
    }
}
