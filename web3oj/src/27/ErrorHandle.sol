// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ErrorHandleProblem {
    string public errorMessage;

    function throwError() public {
        // 여기에 에러를 내는 함수가 작성되어 있습니다.
    }

    function setErrorMessage(string memory _errorMessage) public {
        errorMessage = _errorMessage;
    }
}

contract ErrorHandle {
    function errorHandle(address _errorHandleProblemAddress) public {
        ErrorHandleProblem instance = ErrorHandleProblem(_errorHandleProblemAddress);

        try instance.throwError() {
        } catch Error(string memory reason) {
            instance.setErrorMessage(reason);
        }
    }
}