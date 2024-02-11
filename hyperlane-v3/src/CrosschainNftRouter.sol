// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IMailbox} from "@hyperlane-v3/contracts/interfaces/IMailbox.sol";
import {IRouter} from "@hyperlane-v3/contracts/interfaces/IRouter.sol";
import {TypeCasts} from "@hyperlane-v3/contracts/libs/TypeCasts.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CrosschainNftRouter is Ownable, IRouter {
    error RouteAlreadyEnrolled();
    error RouteNotFound();
    error InvalidInputLength();

    address public mailbox;
    uint32[] private _innerDomains;
    mapping(uint32 => bytes32) private _innerRouters;

    constructor(address _mailbox) Ownable(msg.sender) {
        mailbox = _mailbox;
    }

    function domains() external view override returns (uint32[] memory) {
        return _innerDomains;
    }

    function routers(uint32 _domain) external view override returns (bytes32) {
        return _innerRouters[_domain];
    }

    function enrollRemoteRouter(
        uint32 _domain,
        bytes32 _router
    ) external onlyOwner {
        if (_innerRouters[_domain] != bytes32(0)) {
            revert RouteAlreadyEnrolled();
        }
        _innerRouters[_domain] = _router;
        _innerDomains.push(_domain);
    }

    function enrollRemoteRouters(
        uint32[] calldata _domains,
        bytes32[] calldata _routers
    ) external onlyOwner {
        if (_domains.length != _routers.length) {
            revert InvalidInputLength();
        }

        for (uint256 i = 0; i < _domains.length; i++) {
            if (_innerRouters[_domains[i]] != bytes32(0)) {
                revert RouteAlreadyEnrolled();
            }
            _innerRouters[_domains[i]] = _routers[i];
            _innerDomains.push(_domains[i]);
        }
    }

    function sendNft(
        uint32 _domainId,
        address _to,
        string memory _tokenURI
    ) external payable {
        bytes32 recipientAddress = _tryGetrecipientAddress(_domainId);
        bytes memory messageBody = abi.encode(_to, _tokenURI);

        IMailbox(mailbox).dispatch{value: msg.value}(
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
        bytes32 recipientAddress = _tryGetrecipientAddress(_domainId);
        bytes memory messageBody = abi.encode(_to, _tokenURI);

        return _estimateFee(_domainId, recipientAddress, messageBody);
    }

    function _tryGetrecipientAddress(
        uint32 _domainId
    ) internal view returns (bytes32 recipientAddress) {
        recipientAddress = _innerRouters[_domainId];
        if (recipientAddress == bytes32(0)) {
            revert RouteNotFound();
        }
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
}
