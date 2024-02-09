// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IMailbox} from "@hyperlane/contracts/interfaces/IMailbox.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CrosschainNftRouter is Ownable {
    address public mailbox;

    error NftContractNotFound();
    error InsufficientValueToDispatch();

    mapping(uint32 => address) public domainToNftContract;

    constructor(address _mailbox) Ownable(msg.sender) {
        mailbox = _mailbox;
    }

    function setDomainToNftContract(
        uint32 _domainId,
        address _nftContract
    ) external onlyOwner {
        domainToNftContract[_domainId] = _nftContract;
    }

    function sendNft(
        uint32 _domainId,
        address _to,
        string memory _tokenURI
    ) external payable {
        address nftContract = domainToNftContract[_domainId];
        if (nftContract == address(0)) {
            revert NftContractNotFound();
        }

        bytes32 recipientAddress = addressToBytes32(nftContract);
        bytes memory messageBody = abi.encode(_to, _tokenURI);

        uint256 fee = _estimateFee(_domainId, recipientAddress, messageBody);

        if (fee > msg.value) {
            revert InsufficientValueToDispatch();
        }

        IMailbox(mailbox).dispatch{value: fee}(
            _domainId,
            recipientAddress,
            messageBody
        );
    }

    function estimateFee(
        uint32 _domainId,
        address _to,
        string memory _tokenURI
    ) external view returns (uint256) {
        address nftContract = domainToNftContract[_domainId];
        if (nftContract == address(0)) {
            revert NftContractNotFound();
        }

        bytes32 recipientAddress = addressToBytes32(nftContract);
        bytes memory messageBody = abi.encode(_to, _tokenURI);

        return _estimateFee(_domainId, recipientAddress, messageBody);
    }

    function _estimateFee(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes memory messageBody
    ) internal view returns (uint256) {
        return
            IMailbox(mailbox).quoteDispatch(
                destinationDomain,
                recipientAddress,
                messageBody
            );
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
