// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IERC20Mintable {
    function mint(address to, uint256 amount) external;
}

contract ERC20Mintable {
    IERC20Mintable public token;

    function setToken(address _token) public {
        token = IERC20Mintable(_token);
    }
}

contract MyERC20 is ERC20, ERC20Mintable {
    address public minter;

    modifier onlyMinter() {
        require(_msgSender() == minter, "MyERC20: caller is not the minter");
        _;
    }

    constructor(address _minter) ERC20("Web3 Online Judge Token", "WEB3ojt") {
        minter = _minter;
    }

    function mint(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }
}
