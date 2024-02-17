// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IERC20} from "./interfaces/IERC20.sol";
import {IERC20Metadata} from "./interfaces/IERC20Metadata.sol";
import {IERC20Errors} from "./interfaces/IERC20Errors.sol";

contract ERC20A is IERC20, IERC20Metadata, IERC20Errors {
    /**
     * @dev custom error and its selector
     */
    error StringLengthOver31();
    error ArithmeticOverflow();
    bytes4 private constant STRING_LENGTH_OVER_31 = 0xc1755612;
    bytes4 private constant ARITHMETIC_OVERFLOW = 0xe47ec074;

    /**
     * @dev custom error selectors for ERC-6093
     */
    bytes4 private constant ERC20_INSUFFICIENT_BALANCE = 0xe450d38c;
    bytes4 private constant ERC20_INVALID_SENDER = 0x96c6fd1e;
    bytes4 private constant ERC20_INVALID_RECEIVER = 0xec442f05;
    bytes4 private constant ERC20_INSUFFICIENT_ALLOWANCE = 0xfb8f41b2;
    bytes4 private constant ERC20_INVALID_APPROVER = 0xe602df05;
    bytes4 private constant ERC20_INVALID_SPENDER = 0x94280d62;

    /**
     * @dev ERC-20 event selectors
     */
    bytes32 private constant TRANSFER = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    bytes32 private constant APPROVAL = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    /**
     * @dev ERC-20 state variables
     */
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    /**
     * @dev ERC-20 metadata
     */
    bytes32 private _nameBytes;
    bytes32 private _symbolBytes;
    uint256 private _nameLength;
    uint256 private _symbolLength;

    /**
     * @dev contract constructor
     * @param name_ the name of the token
     * @param symbol_ the symbol of the token
     * @notice the name and symbol must be less than or equal to 31 characters
     */
    constructor(string memory name_, string memory symbol_) {
        bytes memory nameBytes = bytes(name_);
        bytes memory symbolBytes = bytes(symbol_);
        uint256 nameLength = nameBytes.length;
        uint256 symbolLength = symbolBytes.length;

        assembly {
            if or(lt(31, nameLength), lt(31, symbolLength)) { // check if the name or symbol length is greater than 31
                mstore(0, STRING_LENGTH_OVER_31)
                revert(0, 4) // revert with the reason at offset 0 to 4 bytes in memory
            }
        }

        // set the name and symbol metadata
        _nameBytes = bytes32(nameBytes); 
        _symbolBytes = bytes32(symbolBytes);
        _nameLength = nameLength;
        _symbolLength = symbolLength;
    }

    /**
     * @dev returns the name of the token
     */
    function name() public view returns (string memory name_) {
        bytes32 nameBytes = _nameBytes;
        uint256 nameLength = _nameLength;

        assembly {
            name_ := mload(0x40)
            mstore(0x40, add(name_, 0x40))
            mstore(name_, nameLength)
            mstore(add(name_, 0x20), nameBytes)
        }
    }

    /**
     * @dev returns the symbol of the token
     */
    function symbol() public view returns (string memory symbol_) {
        bytes32 symbolBytes = _symbolBytes;
        uint256 symbolLength = _symbolLength;

        assembly {
            symbol_ := mload(0x40)
            mstore(0x40, add(symbol_, 0x40))
            mstore(symbol_, symbolLength)
            mstore(add(symbol_, 0x20), symbolBytes)
        }
    }

    /**
     * @dev returns the number of decimals used to get its user representation
     */
    function decimals() public pure returns (uint8) {
        assembly {
            mstore(0x60, 18)
            return(0x60, 32)
        }
    }

    /**
     * @dev returns the total supply of the token
     */
    function totalSupply() public view returns (uint256 totalSupply_) {
        assembly {
            totalSupply_ := sload(_totalSupply.slot)
        }
    }

    /**
     * @dev returns the balance of the account
     * @param account the address of the account
     */
     function balanceOf(address account) external view returns (uint256 balance_) {
        assembly {
            mstore(0x00, account)
            mstore(0x20, _balances.slot)
            balance_ := sload(keccak256(0x00, 0x40))
        }
     }

    /**
     * @dev transfers `value` amount of tokens to address `to`
     * @param to the address of the recipient
     * @param value the amount of tokens to transfer
     * @return success whether the transfer was successful
     * @notice the caller must have a balance of at least `value`
     * @notice the recipient must be a valid address and not the zero address
     */
    function transfer(address to, uint256 value) external returns (bool success) {
        // get the caller's address
        address from;
        assembly {
            from := caller()
        }

        // transfer the tokens
        _transfer(from, to, value);
        
        // return true
        assembly {
            success := 1
        }
    }

    /**
     * @dev returns the remaining number of tokens that `spender` will be allowed to spend on behalf of `owner` through `transferFrom`
     * @param owner_ the address of the owner
     * @param spender_ the address of the spender
     * @return allowance_ the amount of tokens that `spender` will be allowed to spend on behalf of `owner`
     */
    function allowance(address owner_, address spender_) public view returns (uint256 allowance_) {
        assembly {
            mstore(0x00, owner_)
            mstore(0x20, _allowances.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, spender_)
            allowance_ := sload(keccak256(0x00, 0x40))
        }
    }

    /**
     * @dev sets `value` as the allowance of `spender` over the caller's tokens
     * @param spender the address of the spender
     * @param value the amount of tokens to allow
     * @return success whether the approval was successful
     */
    function approve(address spender, uint256 value) external returns (bool success) {
        address owner_;
        assembly {
            owner_ := caller()
        }

        _approve(owner_, spender, value);

        assembly {
            success := 1
        }
    }

    /**
     * @dev transfers `value` amount of tokens from address `from` to address `to`
     * @param from the address to transfer from
     * @param to the address to transfer to
     * @param value the amount of tokens to transfer
     * @return success whether the transfer was successful
     * @notice the caller must have an allowance of at least `value` for the `from` address
     * @notice the `from` address must have a balance of at least `value`
     * @notice the `to` address must be a valid address and not the zero address
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool success) {
        address spender;
        
        assembly {
            spender := caller()
        }
        
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);

        assembly {
            success := 1
        }
    }

    /**
     * @dev move 'value' tokens from 'from' to 'to'
     * @param from address to transfer from
     * @param to address to transfer to
     * @param value amount of tokens to transfer
     * @notice the caller must have a balance of at least `value`
     * @notice the recipient must be a valid address and not the zero address
     */
    function _transfer(address from, address to, uint256 value) internal virtual {
        // check if the sender is the zero address
        assembly {
            if iszero(from) {
                mstore(0x00, ERC20_INVALID_SENDER)
                mstore(0x04, from)
                revert(0x00, 0x24)
            }
        }

        // check if the recipient is the zero address
        assembly {
            if iszero(to) {
                mstore(0x00, ERC20_INVALID_RECEIVER)
                mstore(0x04, to)
                revert(0x00, 0x24)
            }
        }

        // update the balances
        _update(from, to, value);
    }

    /**
     * @dev updates the balances and total supply
     * @param from the address to transfer from
     * @param to the address to transfer to
     * @param value the amount of tokens to transfer
     */
    function _update(address from, address to, uint256 value) internal virtual {
        // if the sender is the zero address, update the total supply (mint)
        // else, subtract the value from the sender's balance
        assembly {
            switch iszero(from)
            case 1 {
                // check for arithmetic overflow
                let totalSupply_ := sload(_totalSupply.slot)
                let newTotalSupply := add(totalSupply_, value)
                if lt(newTotalSupply, totalSupply_) {
                    mstore(0, ARITHMETIC_OVERFLOW)
                    revert(0, 4)
                }

                // update the total supply
                sstore(_totalSupply.slot, newTotalSupply)
            }
            default {
                // check if the sender has enough balance
                mstore(0x00, from)
                mstore(0x20, _balances.slot)
                let fromBalanceSlot := keccak256(0x00, 0x40)
                let fromBalance := sload(fromBalanceSlot)
                if lt(fromBalance, value) {
                    mstore(0x00, ERC20_INSUFFICIENT_BALANCE)
                    mstore(0x04, from)
                    mstore(0x24, fromBalance)
                    mstore(0x44, value)
                    revert(0x00, 0x64)
                }

                // update the sender's balance
                sstore(fromBalanceSlot, sub(fromBalance, value))
            }
        }

        // if the recipient is the zero address, update the total supply (burn)
        // else, add the value to the recipient's balance
        assembly {
            switch iszero(to)
            case 1 {
                // update the total supply
                sstore(_totalSupply.slot, sub(sload(_totalSupply.slot), value))
            }

            default {
                mstore(0x00, to)
                mstore(0x20, _balances.slot)
                let toBalanceSlot := keccak256(0x00, 0x40)
                let toBalance := sload(toBalanceSlot)

                // update the recipient's balance
                sstore(toBalanceSlot, add(toBalance, value))
            }
        }

        // emit Transfer(from, to, value)
        assembly {
            mstore(0x00, value)
            log3(0x00, 0x20, TRANSFER, from, to)
        }
    }

    /**
     * @dev creates `value` tokens and assigns them to `account`, increasing the total supply
     * @param account the address to which the tokens will be assigned
     * @param value the amount of tokens to be created
     * @notice the recipient must be a valid address and not the zero address
     */
    function _mint(address account, uint256 value) internal {
        // check if the recipient is the zero address
        assembly {
            if iszero(account) {
                mstore(0x00, ERC20_INVALID_RECEIVER)
                mstore(0x04, account)
                revert(0x00, 0x24)
            }
        }

        // update the balances
        _update(address(0), account, value);
    }

    /**
     * @dev destroys `value` tokens from `account`, reducing the total supply
     * @param account the address from which the tokens will be destroyed
     * @param value the amount of tokens to be destroyed
     * @notice the caller must have a balance of at least `value`
     */
    function _burn(address account, uint256 value) internal {
        // check if the sender is the zero address
        assembly {
            if iszero(account) {
                mstore(0x00, ERC20_INVALID_SENDER)
                mstore(0x04, account)
                revert(0x00, 0x24)
            }
        }

        // update the balances
        _update(account, address(0), value);
    }

    /**
     * @dev sets `value` as the allowance of `spender` over the `owner`'s tokens
     * @param owner_ the address of the owner
     * @param spender_ the address of the spender
     * @param value the amount of tokens to allow
     */
    function _approve(address owner_, address spender_, uint256 value) internal {
        _approve(owner_, spender_, value, true);
    }

    /**
     * @dev sets `value` as the allowance of `spender` over the `owner`'s tokens
     * @param owner_ the address of the owner
     * @param spender_ the address of the spender
     * @param value the amount of tokens to allow
     * @param emitEvent whether to emit the Approval event
     * @notice the owner must be a valid address and not the zero address
     * @notice the spender must be a valid address and not the zero address
     */
    function _approve(address owner_, address spender_, uint256 value, bool emitEvent) internal virtual {
        // check if the owner is the zero address
        assembly {
            if iszero(owner_) {
                mstore(0x00, ERC20_INVALID_APPROVER)
                mstore(0x04, owner_)
                revert(0x00, 0x24)
            }
        }

        // check if the spender is the zero address
        assembly {
            if iszero(spender_) {
                mstore(0x00, ERC20_INVALID_SPENDER)
                mstore(0x04, spender_)
                revert(0x00, 0x24)
            }
        }

        // set the allowance
        assembly {
            mstore(0x00, owner_)
            mstore(0x20, _allowances.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, spender_)
            let allowanceSlot := keccak256(0x00, 0x40)
            sstore(allowanceSlot, value)
        }

        // emit Approval(owner_, spender_, value)
        assembly {
            if emitEvent {
                mstore(0x00, value)
                log3(0x00, 0x20, APPROVAL, owner_, spender_)
            }
        }
    }

    /**
     * @dev reduces the allowance of `spender` over the `owner`'s tokens by `value`
     * @param owner_ the address of the owner
     * @param spender_ the address of the spender
     * @param value the amount of tokens to reduce the allowance by
     * @notice the owner must be a valid address and not the zero address
     * @notice the spender must be a valid address and not the zero address
     * @notice the caller must have an allowance of at least `value` for the `spender`
     */
    function _spendAllowance(address owner_, address spender_, uint256 value) internal {
        uint256 currentAllowance = allowance(owner_, spender_);

        // check if the spender has enough allowance to spend from the owner
        if (currentAllowance != type(uint256). max) {
            assembly {
                if lt(currentAllowance, value) {
                    mstore(0x00, ERC20_INSUFFICIENT_ALLOWANCE)
                    mstore(0x04, spender_)
                    mstore(0x24, currentAllowance)
                    mstore(0x44, value)
                    revert(0x00, 0x64)
                }
            }

            // reduce the allowance
            unchecked {
                _approve(owner_, spender_, currentAllowance - value, false);
            }
        }

        // max allowance does not need to be reduced and is not checked
    } 
}
