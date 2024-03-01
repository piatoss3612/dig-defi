// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

contract Utilities is Test {
    bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));

    function getNextUserAddress() external returns (address payable) {
        //bytes32 to address conversion
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    function createPrivateKey() external view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(nextUser)));
    }

    function addressFromPrivateKey(uint256 privateKey) external pure returns (address) {
        return vm.addr(privateKey);
    }

    function fundUser(address payable user, uint256 amount) external {
        vm.deal(user, amount);
    }

    /// @notice create users with 100 ether balance
    function createUsers(uint256 userNum) external returns (address payable[] memory) {
        address payable[] memory users = new address payable[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            address payable user = this.getNextUserAddress();
            vm.deal(user, 100 ether);
            users[i] = user;
        }
        return users;
    }

    /// @notice move block.number forward by a given number of blocks
    function mineBlocks(uint256 numBlocks) external {
        uint256 targetBlock = block.number + numBlocks;
        vm.roll(targetBlock);
    }

    function warpTime(uint256 time) external {
        vm.warp(block.timestamp + time);
    }

    function expandTo18Decimals(uint256 amount) external pure returns (uint256) {
        return amount * 10 ** 18;
    }

    function calcDigest(
        address _owner,
        address _spender,
        uint256 value,
        uint256 nonce,
        bytes32 domainSeparator,
        bytes32 PERMIT_TYPEHASH,
        uint256 deadline
    ) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(abi.encode(PERMIT_TYPEHASH, _owner, _spender, value, nonce, deadline))
            )
        );
    }
}
