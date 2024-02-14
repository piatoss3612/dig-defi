// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRunWithABI2 {
    function getPrivateKey() external view returns (bytes32);
}

contract RunWithABI2Problem {
    bytes32 private privateKey; // 비밀키 저장 변수

    IRunWithABI2 private Iinstance;

    function setRunWithABI2(address _RunWithABI2) public {
        Iinstance = IRunWithABI2(_RunWithABI2);
    }

    /*
    * 비밀키 생성 및 저장하는 함수가 추가로 존재합니다.
    function _______() public {
        
    }
    */
}

contract MyRunWithABI2 {
    bytes32 private privateKey;

    function setPrivateKey(address problemAddress) public {
        // 여기 정답 Contract를 완성하세요
        (bool ok, ) = problemAddress.delegatecall(abi.encodePacked(bytes4(0xa6e5ca07)));
        require(ok, "delegatecall failed");
    }

    // 채점을 위한 함수 입니다.
    function getPrivateKey() public view returns (bytes32) {
        return privateKey;
    }
}
