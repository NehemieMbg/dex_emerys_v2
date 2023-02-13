// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Wallet is Ownable {
    struct Token {
        bytes32 symbol;
        address tokenAddress;
    }

    mapping(bytes32 => Token) public tokens;
    bytes32[] public tokenList;

    mapping(address => mapping(bytes32 => uint256)) public balances;

    modifier tokenExist(bytes32 symbol) {
        require(
            tokens[symbol].tokenAddress != address(0),
            "tokens does not exist"
        );
        _;
    }

    function addToken(bytes32 symbol, address tokenAddress) external onlyOwner {
        tokens[symbol] = Token(symbol, tokenAddress);
        tokenList.push(symbol);
    }

    function deposit(uint amount, bytes32 symbol) external tokenExist(symbol) {
        balances[msg.sender][symbol] += amount;
        IERC20(tokens[symbol].tokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );
    }

    function withdraw(uint amount, bytes32 symbol) external tokenExist(symbol) {
        require(
            balances[msg.sender][symbol] >= amount,
            "Balance not sufficient"
        );

        balances[msg.sender][symbol] -= amount;
        IERC20(tokens[symbol].tokenAddress).transfer(msg.sender, amount);
    }
}
