// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReceiveEtherFunctionProblem {
    address payable public contractAddress; // 이더를 돌려받을 컨트랙트 주소

	// 이더를 돌려받을 컨트랙트 주소 설정하기
    function setReceiveEtherAddress(address payable _contractAddress) public {
        require(_contractAddress.code.length > 0, "_contractAddress is not Contract");
        contractAddress = _contractAddress;
    }

	// 이더리움을 받기위해서 추가로 구현된 함수가 존재합니다.
}

contract ReceiveEther {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}
    fallback() external payable {}

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}