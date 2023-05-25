import React from "react";
import { Card, Button } from "semantic-ui-react";
import Layout from "../components/Layout";
import { Link } from "../routes";
import {
  // permit2 contract address
  PERMIT2_ADDRESS,
  // the type of permit that we need to sign
  PermitTransferFrom,
  // Witness type
  Witness,
  // this will help us get domain, types and values that we need to create a signature
  SignatureTransfer,
} from "@uniswap/permit2-sdk";
import erc20Abi from "../build/contracts/TokenContractAbi.json"
import contractAbi from "../build/contracts/PermitSignature.json"

class VotingIndex extends React.Component {
  static async getInitialProps() {
    const signerOrProvider = "https://polygon-mumbai.g.alchemy.com/v2/vcvZrzGeIs5WzICRvEj3IqaKiVrINq96";
    const erc20 = new ethers.Contract(erc20Address, erc20Abi, signerOrProvider);
    await erc20.approve(PERMIT2_ADDRESS, constants.MaxUint256);
    const contract = new ethers.Contract("0x5de07aEBBA1E1E361daE66396F54aD0CE5D8d194", contractAbi.abi, "https://polygon-mumbai.g.alchemy.com/v2/vcvZrzGeIs5WzICRvEj3IqaKiVrINq96");
    

    return { votings };
  } 

  render() {
    return (
      <div>
        <Layout>
          <h3>Permit Testing</h3>
        </Layout>
      </div>
    );
  }
}

export default VotingIndex;
