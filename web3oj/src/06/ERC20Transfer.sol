// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Transfer {
    ERC20 public web3ojt;

    function setWeb3ojt(address _web3ojt) public {
        web3ojt = ERC20(_web3ojt);
    }
}

contract MyERC20 is ERC20 {
    constructor() ERC20("Web3 Online Judge Token", "WEB3OJT") {
        _mint(msg.sender, 2000000000 * 10 ** decimals());
    }
}
