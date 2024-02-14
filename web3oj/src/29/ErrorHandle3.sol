// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ErrorHandleProblem3 {
    uint private originErrorCode;
    string private originErrorMessage;

    uint private errorCode;
    string private errorMessage;
    
    uint private throwErrorBlockNumber;
    uint private setErrorDataBlockNumber;

    TxLevel private txLevel = TxLevel.END;
    enum TxLevel { BEGIN, END }

    error ErrorData(uint errorCode, string errorMessage);

    modifier TxLevelGuard(TxLevel _txLevel) {
        require(_txLevel == txLevel, "Transaction level error");
        _;
    }

    function txBegin() public {
        throwErrorBlockNumber = block.number;
        originErrorCode = getErrorCode();
        originErrorMessage = getErrorMessage();
        txLevel = TxLevel.BEGIN;
    }

    function throwError() public TxLevelGuard(TxLevel.BEGIN) {
        revert ErrorData(originErrorCode, originErrorMessage);
    }

    function setErrorData(uint _errorCode, string memory _errorMessage) public TxLevelGuard(TxLevel.BEGIN) {
        errorCode = _errorCode;
        errorMessage = _errorMessage;
        setErrorDataBlockNumber = block.number;
        txLevel = TxLevel.END;
    }
    
    function getErrorCode() internal view returns (uint) {
        uint randomHash = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return randomHash % 1000;
    }

    function getErrorMessage() internal view returns (string memory) {
        string memory errorMessage = "abcdefghijklmnopqrstuvwxyz";
        
        // shuffle errorMessage
        for (uint i = 0; i < bytes(errorMessage).length; i++) {
            uint randomIndex = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % bytes(errorMessage).length;
            bytes1 temp = bytes(errorMessage)[i];
            bytes(errorMessage)[i] = bytes(errorMessage)[randomIndex];
            bytes(errorMessage)[randomIndex] = temp;
        }
        
        return errorMessage;
    }

    function valid() public view TxLevelGuard(TxLevel.END) returns (bool) {
        require(errorCode != 0, "Error code is zero");
        require(!strCompare(errorMessage,""), "Error message is empty");

        bool result = errorCode == originErrorCode;
        result = result && strCompare(errorMessage, originErrorMessage);
        result = result && throwErrorBlockNumber == setErrorDataBlockNumber;
        return result;
    }

    function strCompare(string memory _a, string memory _b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((_a))) == keccak256(abi.encodePacked((_b))));
    }
}

contract ErrorHandle {
    function errorHandle(address errorHandle3ProblemAddress) public {
        ErrorHandleProblem3 instance = ErrorHandleProblem3(errorHandle3ProblemAddress);

        instance.txBegin();

        try instance.throwError() {

        } catch (bytes memory lowLevelData) {
            // remove heading 4 bytes which is custom error selector
            bytes memory data = new bytes(lowLevelData.length - 4);
            for (uint i = 4; i < lowLevelData.length; i++) {
                data[i - 4] = lowLevelData[i];
            }

            // decode error data
            (uint errorCode, string memory errorMessage) = abi.decode(data, (uint, string));

            // set error data
            instance.setErrorData(errorCode, errorMessage);            
        }
    }
}