import React from "react";
import Layout from "../components/Layout";
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
// import erc20Abi from "../build/contracts/HilmanToken.json";
import erc20Abi from "../build/contracts/HilmanTokenNew.json";
// import contractAbi from "../build/contracts/PermitSignatureNew.json";
import contractAbi from "../build/contracts/PermitSignatureWithUser.json";
// import contractAbi from "../build/contracts/PermitAllowance.json";
import { ethers } from "ethers";
import { Button } from "semantic-ui-react";
import web3 from "../web3";

class Permit extends React.Component {
  //   const InitialPermit = async () => {
  // }

  erc20Approve = async () => {
    // const rpcUrl = 'https://goerli.infura.io/v3/e66c6786fc4e4498b85dad63f994340c';
    // const provider = new ethers.providers.JsonRpcProvider(rpcUrl);

    const provider = new ethers.providers.Web3Provider((window as any).ethereum);
    const signer = provider.getSigner();

    provider.getNetwork().then(network => {
      console.log('Network:', network.name);
    });

    const erc20Address = "0x9c7dadcB1C5588a05721EF26B70faB583EB1094C"; //token contract address
    // const contractAddress = "0xE11a05a5EF8D721A1e89901a9aC0cd27C10BE285"; //protocol contract address

    const erc20 = new ethers.Contract(
      erc20Address,
      erc20Abi.abi,
      signer
    );
    await erc20.approve(PERMIT2_ADDRESS, ethers.constants.MaxUint256);
  };

      erc20Deposit = async () => {
      // const accounts = await web3.eth.getAccounts();
      const provider = new ethers.providers.Web3Provider((window as any).ethereum);
      const signer = provider.getSigner();

      provider.getNetwork().then(network => {
        console.log('Network:', network.name);
      });
      // console.log(provider);
      // console.log(signer);

      const erc20Address = "0x9c7dadcB1C5588a05721EF26B70faB583EB1094C"; //token contract address
      const contractAddress = "0xAAcfae34Fe8403e0C4e0E8b411a4E4Da2Ac6F619"; //protocol contract address
      const USER_ADDRESS = "0xE5B78452B963Ee246c7043ecEb378367d2b0b862"; //user address

      const amount = ethers.utils.parseEther("2");
      const CHAIN_ID = 80001;
      const ownerAddress = "0x4Ec14E1705CdA4eEb537b25b176B6CF8d8d4E479";

      // const erc20 = new ethers.Contract(
      //   erc20Address,
      //   erc20Abi.abi,
      //   signer
      // );

      const contract = new ethers.Contract(
        contractAddress,
        contractAbi.abi,
        signer
      );

      // const balance = contract.balanceOf(contract.address);

      // console.log(balance);
      console.log(contract.address);

      // const permitSignature = new web3.eth.Contract(
      //   contractAbi.abi,
      //   contractAddress
      // );

      // const ownerContract = await contract.owner();

      // console.log(ownerContract);

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

      // console.log(permit);

      const witness: Witness = {
        // type name that matches the struct that we created in contract
        witnessTypeName: "Witness",
        // type structure that matches the struct
        witnessType: { Witness: [{ name: "user", type: "address" }] },
        // the value of the witness.
        // USER_ADDRESS is the address that we want to give the tokens to
        witness: { user: ownerAddress },
      };

      const { domain, types, values } = SignatureTransfer.getPermitData(
        permit,
        PERMIT2_ADDRESS,
        CHAIN_ID,
        witness
      );
      
      let signature = await signer._signTypedData(domain, types, values);

      // console.log("amount: ", amount);
      // console.log("token address: ", erc20Address);
      // console.log("owner: ", ownerAddress);
      // console.log("permit: ", permit);
      // console.log("signature: ", signature);

      try {
        await contract.deposit(
          amount,
          erc20Address,
          ownerAddress,
          ownerAddress,
          permit,
          signature,
        )

        // await permitSignature.methods
        // .deposit(amount, erc20Address, permit, signature)
        // .send({
        //   from: accounts[0]
        // })
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
          <Button primary onClick={this.erc20Deposit}>Deposit To Protocol Contract Address!</Button>
        </Layout>
      </div>
    );
  }
}

export default Permit;
