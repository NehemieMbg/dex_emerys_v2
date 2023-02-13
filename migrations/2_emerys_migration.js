const Emerys = artifacts.require("Emerys");
const Wallet = artifacts.require("Wallet");

module.exports = async function (deployer, network, accounts) {
  // deployment steps
  await deployer.deploy(Emerys);
  let wallet = await Wallet.deployed();
  let emerys = await Emerys.deployed();
  await emerys.approve(wallet.address, 500);
  await wallet.addToken(web3.utils.fromUtf8("EMRS"), emerys.address);
  await wallet.deposit(100, web3.utils.fromUtf8("EMRS"));
  let balanceOfEmerys = await wallet.balances(
    accounts[0],
    web3.utils.fromUtf8("EMRS")
  );
  console.log(balanceOfEmerys);
};
