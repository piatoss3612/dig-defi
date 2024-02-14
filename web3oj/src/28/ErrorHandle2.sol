// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ErrorHandleProblem2 {
    uint public errorCode;

    function throwError() public {
        // 여기에 에러를 내는 함수가 작성되어 있습니다.
    }

    function setErrorCode(uint _errorCode) public {
        errorCode = _errorCode;
    }
}

contract ErrorHandle2 {
    function errorHandle(address _errorHandleProblem2Address) public {
        ErrorHandleProblem2 instance = ErrorHandleProblem2(_errorHandleProblem2Address);

        try instance.throwError() {
        } catch Panic(uint errorCode) {
            instance.setErrorCode(errorCode);
        }
    }
}