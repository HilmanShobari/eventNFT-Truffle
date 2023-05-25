// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ISignatureTransfer} from "./interfaces/ISignatureTransfer.sol";

contract PermitSignatureNew {
    address public owner;
    string private constant WITNESS_TYPE_STRING = "Witness witness)TokenPermissions(address token,uint256 amount)Witness(address user)";
    bytes32 private constant WITNESS_TYPEHASH = keccak256("Witness(address user)");

    struct Witness {
    // Address of the user that signer is giving the tokens to
    address user;
    }

    ISignatureTransfer public immutable PERMIT2;

    constructor(ISignatureTransfer _permit) {
        owner = msg.sender;
        PERMIT2 = _permit;
    }

    mapping (address => mapping (address => uint256)) public tokenBalancesByUser;

        function deposit(
        uint256 _amount,
        address _token,
        address _owner, // <---
        ISignatureTransfer.PermitTransferFrom calldata _permit,
        bytes calldata _signature
    ) external {
        tokenBalancesByUser[_owner][_token] += _amount; // <---

        PERMIT2.permitTransferFrom(
            _permit,
            ISignatureTransfer.SignatureTransferDetails({
                to: address(this),
                requestedAmount: _amount
            }),
            _owner, // <---
            _signature
        );
    }

    

}