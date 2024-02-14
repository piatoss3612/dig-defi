// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/12/ERC20Permitable.sol";

contract ERC20PermitableScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("ERC20PERMITABLE_INSTANCE");

        Web3OJTPermitable instance = Web3OJTPermitable(instanceAddress);

        bytes32 permitTypeHash = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
        address spender = instanceAddress;
        uint256 value = 20 * 10 ** instance.decimals();
        uint256 nonce = instance.nonces(owner);
        uint256 deadline = block.timestamp + 1 days;

        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                instance.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        permitTypeHash,
                        owner,
                        spender,
                        value,
                        nonce,
                        deadline
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);

        instance.permit(owner, spender, value, deadline, v, r, s);

        vm.stopBroadcast();
    }
}
