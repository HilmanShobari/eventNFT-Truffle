// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ISignatureTransfer} from "./interfaces/ISignatureTransfer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PermitSignatureBatch is Ownable  {
    ISignatureTransfer public immutable PERMIT2;

    constructor(ISignatureTransfer _permit) {
        PERMIT2 = _permit;
    }

    ISignatureTransfer.SignatureTransferDetails[] internal SignatureTransferDetails;

    function deposit(
        uint256[] memory _amount,
        address[] memory _token,
        address[] memory _recipient,
        address _owner,
        ISignatureTransfer.PermitBatchTransferFrom calldata _permit,
        bytes calldata _signature
    ) external {
        delete SignatureTransferDetails;

        for (uint i = 0; i < _token.length; i++) {
            ISignatureTransfer.SignatureTransferDetails storage SignatureTransferDetail = SignatureTransferDetails.push();
            SignatureTransferDetail.to = _recipient[i];
            SignatureTransferDetail.requestedAmount = _amount[i];
        }

        PERMIT2.permitTransferFrom(
            _permit,
            SignatureTransferDetails,
            _owner,
            _signature
        );
    }
}