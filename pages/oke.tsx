export const deposit = async (amount) => {

    const provider = new ethers.providers.Web3Provider((window as any).ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(process.env.NEXT_PUBLIC_VAULT_ADDRESS as string, qoinpayAbi, signer);
    const permit: PermitTransferFrom = {
      permitted: {
        // token we are permitting to be transferred
        token: process.env.NEXT_PUBLIC_TOKEN_ADDRESS as string,
        // amount we are permitting to be transferred
        amount: ethers.utils.parseEther(amount)
      },
      // who can transfer the tokens
      spender: process.env.NEXT_PUBLIC_VAULT_ADDRESS as string,
      nonce: parseInt((Math.random() * 10**9).toString()),
      // signature deadline
      deadline: ethers.constants.MaxUint256
    };
  
    const witness: Witness = {
      // type name that matches the struct that we created in contract
      witnessTypeName: 'Witness',
      // type structure that matches the struct
      witnessType: { Witness: [{ name: 'user', type: 'address' }] },
      // the value of the witness.
      // USER_ADDRESS is the address that we want to give the tokens to
      witness: { user: process.env.NEXT_PUBLIC_QOINPAYHOLDINGACCOUNT_ADDRESS },
    }
  
    console.log(permit)
    console.log(witness)
    const { domain, types, values } = SignatureTransfer.getPermitData(permit, PERMIT2_ADDRESS, 80001, witness);
    let signature = await signer._signTypedData(domain, types, values);
  
    console.log(signature)
    console.log(provider)
    try {
      await contract.depositERC20(process.env.NEXT_PUBLIC_TOKEN_ADDRESS,ethers.utils.parseEther(amount), permit.nonce, permit.deadline, signature).then((result) => {
        console.log(result);
      });
      // await contract.transferERC20(process.env.NEXT_PUBLIC_TOKEN_ADDRESS, process.env.NEXT_PUBLIC_QOINPAYHOLDINGACCOUNT_ADDRESS, ethers.utils.parseEther(amount), permit.nonce, permit.deadline, signature).then((result) => {
      //   console.log(result);
      // });
  
    } catch (error) {
      // handle error
      console.log(error);
    }
  };