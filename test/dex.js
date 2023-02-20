const Dex = artifacts.require("Dex");
const Emerys = artifacts.require("Emerys");
const truffleAssert = require("truffle-assertions");

contract("Dex", (accounts) => {
  it("throw an error if Eth balance is too low when creating BUY limit order", async () => {
    let dex = await Dex.deployed();
    let emerys = await Emerys.deployed();
    await truffleAssert.reverts(
      dex.createLimitOrder(0, emerys.address, 1000, 1)
    );
    await dex.depositEth({ value: 100 });
    await truffleAssert.passes(dex.createLimitOrder(0, emerys.address, 10, 1));
  });

  it("throw an error if token balance is too low when creating SELL order", async () => {
    let dex = await Dex.deployed();
    let emerys = await Emerys.deployed();
    await truffleAssert.reverts(dex.createLimitOrder(1, emerys.address, 10, 1));
    await emerys.approve(dex.address, 500);
    await dex.addToken(web3.utils.fromUtf8("EMRS"), emerys.address, {
      from: accounts[0],
    });
    await dex.deposit(10, emerys.address);
    await truffleAssert.passes(dex.createLimitOrder(1, emerys.address, 10, 1));
  });

  it("BUY order book should be ordered on price from highest to lowest", async () => {
    let dex = await Dex.deployed();
    let emerys = await Emerys.deployed();
    await emerys.approve(dex.address, 500);
    await dex.depositEth({ value: 3000 });
    await dex.createLimitOrder(0, emerys.address, 1, 200);
    await dex.createLimitOrder(0, emerys.address, 1, 100);
    await dex.createLimitOrder(0, emerys.address, 1, 300);

    let orderbook = await dex.getOrderBook(emerys.address, 0);
    assert(orderbook.length > 0);
    console.log(orderbook);

    for (let i = 0; i < orderbook.length - 1; i++) {
      assert(
        orderbook[i].price >= orderbook[i + 1].price,
        "not right order in buy book"
      );
    }
  });

  it("SELL order book should be ordered on price from lowest to highest", async () => {
    let dex = await Dex.deployed();
    let emerys = await Emerys.deployed();
    await emerys.approve(dex.address, 500);
    await dex.createLimitOrder(1, emerys.address, 1, 200);
    await dex.createLimitOrder(1, emerys.address, 1, 100);
    await dex.createLimitOrder(1, emerys.address, 1, 300);

    let orderbook = await dex.getOrderBook(emerys.address, 1);
    console.log(orderbook);
    for (let i = 0; i < orderbook.length - 1; i++) {
      assert(
        orderbook[i].price <= orderbook[i + 1].price,
        "not right order in sell book"
      );
    }
  });
});
