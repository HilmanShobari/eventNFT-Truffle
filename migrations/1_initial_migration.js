const Migrations = artifacts.require("PermitSignatureGSN"); //nama file contract yang ingin di deploy 0x8407474e00a58497feEeE889A3eC4b81b6c23923

module.exports = function (deployer) {
  deployer.deploy(Migrations, "0x000000000022D473030F116dDEE9F6B43aC78BA3", "0xB2b5841DBeF766d4b521221732F9B618fCf34A87"); //address uniswap permit2
};


// const PermitSignature = artifacts.require("PermitSignature");
// const SignatureTransfer = artifacts.require("SignatureTransfer");

// module.exports = function(deployer) {
//   deployer.deploy(SignatureTransfer).then(function() {
//     return deployer.deploy(PermitSignature, SignatureTransfer.address);
//   });
// };
