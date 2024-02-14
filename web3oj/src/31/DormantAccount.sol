// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract DormantAccount {
    
}

contract Injection {
    constructor(address payable _dormantAccount) payable {
        require(msg.value > 0);

        selfdestruct(_dormantAccount);
    }
}