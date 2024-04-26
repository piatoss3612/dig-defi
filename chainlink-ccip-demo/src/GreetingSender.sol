// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Warp, Client} from "./Warp.sol";

contract GreetingSender is Warp {
    event GreetingSent(bytes32 id, string greeting);

    constructor(address router, address link) Warp(router, link) {}

    function sendGreeting(uint64 dstChainSelector, string memory greeting) external onlyOwner {
        bytes memory data = abi.encode(greeting);
        bytes32 messageId = _sendMessage(dstChainSelector, data);
        emit GreetingSent(messageId, greeting);
    }

    function _handleMessageWithTokens(address, bytes memory, Client.EVMTokenAmount[] memory)
        internal
        virtual
        override
    {
        revert("never receive tokens");
    }

    function _handleMessage(address, bytes memory) internal virtual override {
        revert("never receive messages");
    }
}
