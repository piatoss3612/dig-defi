// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Warp, Client} from "./Warp.sol";

contract TokenReceiver is Warp {
    constructor(address router, address link) Warp(router, link) {}

    event MessageReceived(address sender, bytes data);
    event TokenReceived(address token, uint256 amount);

    function _handleMessageWithTokens(address sender, bytes memory data, Client.EVMTokenAmount[] memory tokens)
        internal
        virtual
        override
    {
        emit MessageReceived(sender, data);
        for (uint256 i = 0; i < tokens.length; i++) {
            emit TokenReceived(tokens[i].token, tokens[i].amount);
        }
    }

    function _handleMessage(address sender, bytes memory data) internal virtual override {
        emit MessageReceived(sender, data);
    }
}
