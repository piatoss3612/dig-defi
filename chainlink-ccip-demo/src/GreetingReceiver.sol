// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Warp, Client} from "./Warp.sol";

contract GreetingReceiver is Warp {
    uint256 messageCount;

    mapping(uint256 => string) public messages;

    event GreetingReceived(uint256 id, string greeting);

    constructor(address router, address link) Warp(router, link) {}

    function sendGreeting(uint64 dstChainSelector, string memory greeting) external onlyOwner {
        bytes memory data = abi.encode(greeting);
        _sendMessage(dstChainSelector, data);
    }

    function _handleMessageWithTokens(address, bytes memory, Client.EVMTokenAmount[] memory)
        internal
        virtual
        override
    {
        revert("never receive");
    }

    function _handleMessage(address, bytes memory data) internal virtual override {
        string memory greeting = abi.decode(data, (string));
        uint256 id = messageCount++;
        messages[id] = greeting;

        emit GreetingReceived(id, greeting);
    }
}
