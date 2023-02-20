const Emerys = artifacts.require("Emerys");
const Dex = artifacts.require("Dex");

module.exports = async function (deployer, network, accounts) {
  // deployment steps
  await deployer.deploy(Emerys);
};
