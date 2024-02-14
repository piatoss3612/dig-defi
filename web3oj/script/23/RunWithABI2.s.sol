// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../../src/23/RunWithABI2.sol";

contract RunWithABI2Script is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address instanceAddress = vm.envAddress("RUN_WITH_ABI2_INSTANCE");

        RunWithABI2Problem instance = RunWithABI2Problem(instanceAddress);

        MyRunWithABI2 solver = new MyRunWithABI2();

        // 비밀키 생성을 위해 caller를 사용하므로 delegatecall(caller=비밀키 소유자)을
        // 사용하는 경우와 동일한 결과를 얻기 위해서는 call을 사용해 문제 인스턴스의 비밀키를
        // 생성해 주고, 솔루션 인스턴스의 setPrivateKey를 호출해야 합니다.
        (bool ok, ) = instanceAddress.call(abi.encodePacked(bytes4(0xa6e5ca07)));
        require(ok, "call failed");

        solver.setPrivateKey(instanceAddress);
        instance.setRunWithABI2(address(solver));

        vm.stopBroadcast();
    }
}
