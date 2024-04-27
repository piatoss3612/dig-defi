// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IWarp} from "./interfaces/IWarp.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/v0.8/interfaces/LinkTokenInterface.sol";
import {OwnerIsCreator} from "@chainlink/contracts/v0.8/shared/access/OwnerIsCreator.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Warp is IWarp, CCIPReceiver, OwnerIsCreator {
    address public immutable LINK;
    mapping(uint64 chainSelector => address supportedWarp) private _warps;

    constructor(address router, address link) CCIPReceiver(router) {
        LINK = link;
        LinkTokenInterface(link).approve(router, type(uint256).max);
    }

    function getSupportedWarp(uint64 chainSelector) external view returns (address) {
        return _getSupportedWarp(chainSelector);
    }

    function setSupportedWarp(uint64 chainSelector, address warp) external onlyOwner {
        _warps[chainSelector] = warp;
        emit SupportedWarpSet(chainSelector, warp);
    }

    function _sendMessage(uint64 dstChainSelector, bytes memory data) internal returns (bytes32 messageId) {
        address supportedWarp = _getSupportedWarp(dstChainSelector);
        if (supportedWarp == address(0)) {
            revert InvalidWarp(supportedWarp);
        }

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(supportedWarp),
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: LINK
        });

        messageId = _sendMessage(dstChainSelector, message);
    }

    function _sendMessageWithToken(uint64 dstChainSelector, address token, uint256 amount, bytes memory data)
        internal
        returns (bytes32 messageId)
    {
        address supportedWarp = _getSupportedWarp(dstChainSelector);
        if (supportedWarp == address(0)) {
            revert InvalidWarp(supportedWarp);
        }

        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({token: token, amount: amount});

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(supportedWarp),
            data: data,
            tokenAmounts: tokenAmounts,
            extraArgs: "",
            feeToken: LINK
        });

        bool ok = IERC20(token).transferFrom(msg.sender, address(this), amount);
        if (!ok) {
            revert FailToTransferTokenFromSender();
        }

        ok = IERC20(token).approve(getRouter(), amount);
        if (!ok) {
            revert FailedToApproveToken(token, amount);
        }

        messageId = _sendMessage(dstChainSelector, message);
    }

    function _sendMessage(uint64 dstChainSelector, Client.EVM2AnyMessage memory message)
        private
        returns (bytes32 messageId)
    {
        IRouterClient router = IRouterClient(getRouter());

        uint256 fee = router.getFee(dstChainSelector, message);
        uint256 nativeFee;

        if (LinkTokenInterface(LINK).balanceOf(address(this)) < fee) {
            message.feeToken = address(0);
            nativeFee = router.getFee(dstChainSelector, message);
            if (nativeFee > address(this).balance) {
                revert InsufficientFundsForFee();
            }
        }

        messageId = router.ccipSend{value: nativeFee}(dstChainSelector, message);

        emit MessageSent(dstChainSelector, messageId);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal virtual override {
        address supportedWarp = _getSupportedWarp(message.sourceChainSelector);
        address sender = _getSender(message.sender);
        if (sender != supportedWarp) {
            revert InvalidWarp(sender);
        }

        if (message.destTokenAmounts.length > 0) {
            _handleMessageWithTokens(sender, message.data, message.destTokenAmounts);
        } else {
            _handleMessage(sender, message.data);
        }
    }

    function _handleMessageWithTokens(
        address sender,
        bytes memory data,
        Client.EVMTokenAmount[] memory destTokenAmounts
    ) internal virtual;

    function _handleMessage(address sender, bytes memory data) internal virtual;

    function _getSupportedWarp(uint64 chainSelector) internal view returns (address) {
        address warp = _warps[chainSelector];
        if (warp == address(0)) {
            revert UnsupportedChain(chainSelector);
        }
        return warp;
    }

    function _getSender(bytes memory encodedSender) internal pure returns (address) {
        return abi.decode(encodedSender, (address));
    }

    receive() external payable {}
}
