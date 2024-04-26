// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IWarp {
    error UnsupportedChain(uint64 chainSelector);
    error InvalidWarp(address warp);
    error InsufficientFundsForFee();
    error FailedToApproveToken(address token, uint256 amount);

    event SupportedWarpSet(uint64 indexed chainSelector, address indexed warp);
    event MessageSent(uint64 indexed dstChainSelector, bytes32 indexed messageId);

    function getSupportedWarp(uint64 chainSelector) external view returns (address);
    function setSupportedWarp(uint64 chainSelector, address warp) external;
}
