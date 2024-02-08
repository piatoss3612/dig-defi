// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import "@layerzero-contracts/lzApp/NonblockingLzApp.sol";

/**
 * @title LayerZeroSwap_Mumbai
 * @dev This contract sends a cross-chain message from Mumbai to Sepolia to transfer ETH in return for deposited MATIC.
 */
contract LayerZeroV1Swap is NonblockingLzApp {
    // State variables for the contract
    uint16 public destChainId;

    mapping(uint64 => Receipt) public receipts;

    struct Receipt {
        address to;
        uint amount;
    }

    /**
     * @dev Constructor that initializes the contract with the LayerZero endpoint.
     * @param _lzEndpoint Address of the LayerZero endpoint.
     */
    constructor(
        address _lzEndpoint
    ) NonblockingLzApp(_lzEndpoint) Ownable(msg.sender) {
        // If Source == Sepolia, then Destination Chain = Mumbai
        if (_lzEndpoint == 0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1)
            destChainId = 10109;

        // If Source == Mumbai, then Destination Chain = Sepolia
        if (_lzEndpoint == 0xf69186dfBa60DdB133E91E9A4B5673624293d8F8)
            destChainId = 10161;
    }

    function trustAddress(address _otherContract) public onlyOwner {
        trustedRemoteLookup[destChainId] = abi.encodePacked(
            _otherContract,
            address(this)
        );
    }

    function estimateFees(
        bytes calldata adapterParams,
        address receiver,
        uint amount
    ) public view returns (uint nativeFee, uint zroFee) {
        //Input the message you plan to send.
        bytes memory payload = abi.encode(receiver, amount);

        // Call the estimateFees function on the lzEndpoint contract.
        // This function estimates the fees required on the source chain, the destination chain, and by the LayerZero protocol.
        return
            lzEndpoint.estimateFees(
                destChainId,
                address(this),
                payload,
                false,
                adapterParams
            );
    }

    /**
     * @dev Allows users to swap to ETH.
     * @param receiver Address of the receiver.
     */
    function swapToETH(address receiver, uint amount) public payable {
        require(receiver != address(0), "Invalid receiver address");
        require(amount > 0, "Invalid amount");
        require(msg.value >= amount, "Amount exceeds value sent");

        // The message is encoded as bytes and stored in the "payload" variable.
        bytes memory payload = abi.encode(receiver, amount);

        _lzSend(
            destChainId,
            payload,
            payable(msg.sender),
            address(0x0),
            bytes(""),
            msg.value - amount
        );
    }

    /**
     * @dev Internal function to handle incoming LayerZero messages.
     */
    function _nonblockingLzReceive(
        uint16,
        bytes memory,
        uint64 _nonce,
        bytes memory _payload
    ) internal override {
        (address receiver, uint amount) = abi.decode(_payload, (address, uint));

        require(receiver != address(0), "Invalid receiver address");
        require(amount > 0, "Invalid amount");

        (bool success, ) = receiver.call{value: amount}("");
        require(success, "Transfer failed");

        receipts[_nonce] = Receipt(receiver, amount);
    }

    // Fallback function to receive ether
    receive() external payable {}

    /**
     * @dev Allows the owner to withdraw all funds from the contract.
     */
    function withdrawAll() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
