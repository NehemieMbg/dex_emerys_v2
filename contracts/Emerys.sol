// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Emerys is ERC20 {
    constructor() ERC20("Emerys", "EMRS") {
        _mint(msg.sender, 1000);
    }
}
