const Dex = artifacts.require("Dex");
const Emerys = artifacts.require("Emerys");
const truffleAssert = require("truffle-assertions");

contract("Dex", (accounts) => {
  it("should only be possible for owner to add tokens", async () => {
    let dex = await Dex.deployed();
    let emerys = await Emerys.deployed();
    await truffleAssert.passes(
      dex.addToken(web3.utils.fromUtf8("EMRS"), emerys.address, {
        from: accounts[0],
      })
    );

    await truffleAssert.reverts(
      dex.addToken(web3.utils.fromUtf8("EMRS"), emerys.address, {
        from: accounts[1],
      })
    );
  });

  it("should handle deposits", async () => {
    let dex = await Dex.deployed();
    let emerys = await Emerys.deployed();
    await emerys.approve(dex.address, 500);
    await dex.deposit(100, emerys.address);

    let balance = await dex.balances(accounts[0], emerys.address);
    assert.equal(balance.toNumber(), 100);
  });

  it("should handle withdrawals", async () => {
    let dex = await Dex.deployed();
    let emerys = await Emerys.deployed();
    await truffleAssert.passes(dex.withdraw(50, emerys.address));
  });

  it("should handle faulty withdrawals", async () => {
    let dex = await Dex.deployed();
    let emerys = await Emerys.deployed();
    await truffleAssert.reverts(dex.withdraw(500, emerys.address));
  });
});
