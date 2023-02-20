const Dex = artifacts.require("Dex");

module.exports = function (deployer) {
  // deployment steps
  deployer.deploy(Dex);
};
