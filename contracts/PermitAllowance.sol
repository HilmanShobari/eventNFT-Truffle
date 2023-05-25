// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {IAllowanceTransfer} from "./interfaces/IAllowanceTransfer.sol";

contract PermitAllowance {
address public owner;
IAllowanceTransfer public immutable PERMIT2;

constructor(IAllowanceTransfer _permit) {
    owner = msg.sender;
    PERMIT2 = _permit;
}

    mapping (address => mapping (address => uint256)) public tokenBalancesByUser;

    function deposit(
        uint160 _amount,
        address _token
        // IAllowanceTransfer.PermitSingle calldata _permit,
        // bytes calldata _signature
    ) external {
        tokenBalancesByUser[msg.sender][_token] += _amount;

        // 1. Set allowance using permit
        // PERMIT2.permit(
        //     // Owner of the tokens and signer of the message.
        //     msg.sender,
        //     // The permit message.
        //     _permit,
        //     // The packed signature that was the result of signing
        //     // the EIP712 hash of `_permit`.
        //     _signature
        // );

        // 2. Transfer the tokens
        PERMIT2.transferFrom(
            msg.sender,
            address(this),
            _amount,
            _token
        );
    }

    // function deposit(
    //     uint160 _amount,
    //     address _token
    // ) external {
    //     tokenBalancesByUser[msg.sender][_token] += _amount;

    //     PERMIT2.transferFrom(
    //         msg.sender,
    //         address(this),
    //         _amount,
    //         _token
    //     );
    // }

}