// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Warp, Client} from "./Warp.sol";

contract TokenSender is Warp {
    constructor(address router, address link) Warp(router, link) {}

    event TokenSent(bytes32 messageId, uint64 dstChainSelector, address token, uint256 amount);

    function sendToken(uint64 dstChainSelector, address token, uint256 amount) external {
        if (token == address(0)) {
            revert("token address is zero");
        }

        if (amount == 0) {
            revert("amount is zero");
        }

        bytes32 messageId = _sendMessageWithToken(dstChainSelector, token, amount, "");

        emit TokenSent(messageId, dstChainSelector, token, amount);
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
