import { ethers } from "ethers";
import dex = require("../build/contracts/Dex.json");

const provider = new ethers.JsonRpcApiProvider("http://127.0.0.1:9545/");
const dexAddress = "0xDe90cc32EDabbd1c639e866f7bd265B9465C23D4";
const dexAbi = Dex.abi;
console.log(Dex);
