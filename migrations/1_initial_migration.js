const Migrations = artifacts.require("PermitSignatureBatch");

module.exports = function (deployer) {
  deployer.deploy(Migrations, "0x000000000022D473030F116dDEE9F6B43aC78BA3"); //address uniswap permit2
};