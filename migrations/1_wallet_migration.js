const Wallet = artifacts.require("Wallet");

module.exports = function (deployer) {
  // deployment steps
  deployer.deploy(Wallet);
};
