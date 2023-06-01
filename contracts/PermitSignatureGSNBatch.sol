// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ISignatureTransfer} from "./interfaces/ISignatureTransfer.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PermitSignatureGSNBatch is ERC2771Recipient, Ownable  {
    string public yangPunya = "Hilman";

    string private constant WITNESS_TYPE_STRING = "Witness witness)TokenPermissions(address token,uint256 amount)Witness(address user)";
    bytes32 private constant WITNESS_TYPEHASH = keccak256("Witness(address user)");

    struct Witness {
        // Address of the user that signer is giving the tokens to
        address user;
    }

    ISignatureTransfer public immutable PERMIT2;

    constructor(ISignatureTransfer _permit, address forwarder) {
        PERMIT2 = _permit;
        _setTrustedForwarder(forwarder);
    }

    ISignatureTransfer.SignatureTransferDetails[] internal SignatureTransferDetails;

    mapping (address => mapping (address => uint256)) public tokenBalancesByUser;

    function deposit(
        uint256[] memory _amount,
        address[] memory _token,
        address[] memory _recipient,
        uint totTypesOfToken,
        address _owner,
        address _user,
        ISignatureTransfer.PermitBatchTransferFrom calldata _permit,
        bytes calldata _signature
    ) external {
        delete SignatureTransferDetails;

        for (uint i = 0; i <= totTypesOfToken - 1; i++) {
            tokenBalancesByUser[_user][_token[i]] += _amount[i];
            ISignatureTransfer.SignatureTransferDetails storage SignatureTransferDetail = SignatureTransferDetails.push();
            SignatureTransferDetail.to = _recipient[i];
            SignatureTransferDetail.requestedAmount = _amount[i];
        }

        PERMIT2.permitWitnessTransferFrom(
            _permit,
            SignatureTransferDetails,
            _owner,
            // witness
            keccak256(abi.encode(WITNESS_TYPEHASH,Witness(_user))),
            // witnessTypeString,
            WITNESS_TYPE_STRING,
            _signature
        );
    }

    function _msgSender() internal view override(Context, ERC2771Recipient)
        returns (address sender) {
        sender = ERC2771Recipient._msgSender();
    }

    function _msgData() internal view override(Context, ERC2771Recipient)
        returns (bytes calldata) {
        return ERC2771Recipient._msgData();
    }
}