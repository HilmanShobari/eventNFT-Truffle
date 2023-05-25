import React from "react";
import Layout from "../components/Layout";
import { Button } from "semantic-ui-react";
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
import erc20Abi from "../build/contracts/HilmanToken.json";
import contractAbi from "../build/contracts/PermitSignatureNew.json";
import { ethers } from "ethers";
import web3 from "../web3";

// interface PermitTestingProps {
//   erc20Name: string;
//   erc20Owner: string;
//   erc20OwnerBalance: string;
//   erc20Address: string;
//   contractAddress: string;
// }

class PermitTesting extends React.Component {
  state = {
  };

  componentDidMount() {
  }

  // static async getInitialProps() {
    // const erc20Address = "0x61B72666448cb783F99B2e6Bb403d5e782643a40"; //token contract address
    // const contractAddress = "0xc354051aaAd24427fb28cec51C015581e6971810"; //protocol contract address

    // const erc20 = new web3.eth.Contract(erc20Abi.abi, erc20Address);

    // const erc20Name = await erc20.methods.name().call();
    // const erc20Owner = await erc20.methods.owner().call();
    // const erc20OwnerBalance = await erc20.methods.balanceOf(erc20Owner).call();

    // return { erc20Address, erc20Name, erc20Owner, erc20OwnerBalance, contractAddress };
  // }

  erc20Approve = async () => {
    const accounts = await web3.eth.getAccounts();
    const account = accounts[0];
    const erc20Address = "0x61B72666448cb783F99B2e6Bb403d5e782643a40"; //token contract address
    const erc20 = new web3.eth.Contract(erc20Abi.abi, erc20Address);

    await erc20.methods.approve(PERMIT2_ADDRESS, ethers.constants.MaxUint256).send({
      from: account,
    });
  };

  erc20Deposit = async () => {
    const accounts = await web3.eth.getAccounts();
    const account = accounts[0];
    const USER_ADDRESS = "0xE5B78452B963Ee246c7043ecEb378367d2b0b862"; //address that gets permission to approve

    const mnemonic = "swallow radio panda endless bicycle arena story winter ahead dismiss decade multiply"
    const wallet = ethers.Wallet.fromMnemonic(mnemonic)

    const erc20Address = "0x61B72666448cb783F99B2e6Bb403d5e782643a40"; //token contract address
    const contractAddress = "0xc354051aaAd24427fb28cec51C015581e6971810"; //protocol contract address

    const permitSignature = new web3.eth.Contract(
      contractAbi.abi,
      contractAddress
    );

    const ownerContract = await permitSignature.methods.owner();

    const ownerAddress = "0x4Ec14E1705CdA4eEb537b25b176B6CF8d8d4E479";

    console.log(ownerContract);

    const amount = "2000000000000000000";
    const CHAIN_ID = 80001;

    console.log(PERMIT2_ADDRESS);

    const permit: PermitTransferFrom = {
      permitted: {
        // token we are permitting to be transferred
        token: erc20Address,
        // amount we are permitting to be transferred
        amount: amount,
      },
      // who can transfer the tokens
      spender: contractAddress,
      nonce: parseInt((Math.random() * 10**9).toString()),
      // signature deadline
      deadline: ethers.constants.MaxUint256,
    };

    const witness: Witness = {
      // type name that matches the struct that we created in contract
      witnessTypeName: "Witness",
      // type structure that matches the struct
      witnessType: { Witness: [{ name: "user", type: "address" }] },
      // the value of the witness.
      // USER_ADDRESS is the address that we want to give the tokens to
      witness: { user: USER_ADDRESS },
    };

    const { domain, types, values } = SignatureTransfer.getPermitData(
      permit,
      PERMIT2_ADDRESS,
      CHAIN_ID,
      witness
    );
    
    let signature = await wallet._signTypedData(domain, types, values);

    await permitSignature.methods.deposit(
      amount,
      erc20Address,
      ownerAddress,
      permit,
      signature
    ).send({
      from: account
    })

    // await permitSignature.deposit(
    //   amount,
    //   erc20Address,
    //   account,
    //   USER_ADDRESS,
    //   permit,
    //   signature
    // );
  }

  render() {
    // const { erc20Address, erc20Name, erc20Owner, erc20OwnerBalance, contractAddress } = this.props;
    return (
      <div>
        <Layout>
          <h3>Permit Testing</h3>
          {/* <h3>Token Name : {erc20Name}</h3>
          <h3>Token Address: {erc20Address}</h3>
          <h3>Token Owner : {erc20Owner}</h3>
          <h3>Token Owner Balance : {erc20OwnerBalance}</h3>

          <h3>Protocol Contract Address : {contractAddress}</h3> */}

          <Button primary onClick={this.erc20Approve}>Approve Protocol Contract Address!</Button>
          <Button primary onClick={this.erc20Deposit}>Deposit To Protocol Contract Address!</Button>
        </Layout>
      </div>
    );
  }
}

export default PermitTesting;
