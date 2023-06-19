import React from "react";
import Layout from "../components/Layout";
import {
  PERMIT2_ADDRESS, // permit2 contract address
  PermitBatchTransferFrom,
  SignatureTransfer, // this will help us get domain, types and values that we need to create a signature
} from "@uniswap/permit2-sdk";
import erc20Abi from "../build/contracts/HilmanTokenNew.json"; //every ERC20 has same Abi
import contractAbi from "../build/contracts/PermitSignatureBatch.json";
import { ethers } from "ethers";
import { Button } from "semantic-ui-react";

class Permit extends React.Component {
    erc20Approve = async () => {
      const provider = new ethers.providers.Web3Provider((window as any).ethereum);
      const signer = provider.getSigner();

      console.log(await signer.getAddress());

      const erc20Address = "0x01F2f17b3737d60ED2800eA208D6b5580540C90a"; //approve QOIN and QBRIDGE Token one by one

      const erc20 = new ethers.Contract(
        erc20Address,
        erc20Abi.abi,
        signer
      );
      
      await erc20.approve(PERMIT2_ADDRESS, ethers.constants.MaxUint256);
    };

    erc20Deposit = async () => {
    const provider = new ethers.providers.Web3Provider((window as any).ethereum);
    const signer = provider.getSigner();

    provider.getNetwork().then(network => {
      console.log('Network:', network.name);
    });

    const ownerAddress = await signer.getAddress();

    const contractAddress = "0xA1793f359832366241f8c5F7Ab515605BAbB7062"; //protocol contract address

    const erc20Address = ["0xB8E9C88Ab7011a3935F0C0AacdA78b76A6d764B8", "0x01F2f17b3737d60ED2800eA208D6b5580540C90a"]; //token contract address (QOIN, QBRIDGE)

    const recipient = ["0xFFCCae7D0506bfD25b9F0d41813C0392f1E637EC", "0xFFCCae7D0506bfD25b9F0d41813C0392f1E637EC"];

    const amount = [ethers.utils.parseEther("1"),ethers.utils.parseEther("1")];
    const CHAIN_ID = 80001;

    const contract = new ethers.Contract(
      contractAddress,
      contractAbi.abi,
      signer
    );

    console.log(contract.address);
    
    let permitted = [];

    for (let i = 0; i < erc20Address.length; i++) {
      permitted.push({
        token: erc20Address[i],
        amount: amount[i],
      })
    }

    const permit: PermitBatchTransferFrom = {
      permitted: permitted,
      // who can transfer the tokens
      spender: contractAddress,
      nonce: parseInt((Math.random() * 10**9).toString()),
      // signature deadline
      deadline: ethers.constants.MaxUint256,
    };

    console.log("permit :", permit);

    const { domain, types, values } = SignatureTransfer.getPermitData(
      permit,
      PERMIT2_ADDRESS,
      CHAIN_ID,
    );
    
    let signature = await signer._signTypedData(domain, types, values);

    try {
      await contract.deposit( //transfer function to batch addresses
        amount,
        erc20Address,
        recipient,
        ownerAddress,
        permit,
        signature,
      )
      .then((result) => {console.log(result)});
    } catch (err) {
      console.log(err);
    }
  };

  render() {
    return (
      <div>
        <Layout>
          <h3>Permit Testing</h3>
          <Button primary onClick={this.erc20Approve}>Approve Protocol Contract Address!</Button>
          <Button primary onClick={this.erc20Deposit}>Transfer Tokens To Addresses!</Button>
        </Layout>
      </div>
    );
  }
}

export default Permit;
