// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Wallet is Ownable {
    struct Token {
        bytes32 symbol;
        address tokenAddress;
    }

    mapping(address => Token) public tokens;
    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => uint) public ethBalance;

    bytes32[] public tokenList;

    modifier tokenExist(address tokenAddress) {
        require(
            tokens[tokenAddress].tokenAddress != address(0),
            "tokens does not exist"
        );
        _;
    }

    function addToken(bytes32 symbol, address tokenAddress) external onlyOwner {
        tokens[tokenAddress] = Token(symbol, tokenAddress);
        tokenList.push(symbol);
    }

    function deposit(
        uint amount,
        address tokenAddress
    ) external tokenExist(tokenAddress) {
        balances[msg.sender][tokenAddress] += amount;
        IERC20(tokens[tokenAddress].tokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );
    }

    function withdraw(
        uint amount,
        address tokenAddress
    ) external tokenExist(tokenAddress) {
        require(
            balances[msg.sender][tokenAddress] >= amount,
            "Balance not sufficient"
        );

        balances[msg.sender][tokenAddress] -= amount;
        IERC20(tokens[tokenAddress].tokenAddress).transfer(msg.sender, amount);
    }

    function depositEth() external payable {
        ethBalance[msg.sender] += msg.value;
    }
}
