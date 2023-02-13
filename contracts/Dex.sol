// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./Wallet.sol";

contract Dex is Wallet {
    enum Position {
        Buy, // 0
        Sell // 1
    }

    struct Order {
        uint id;
        address trader;
        Position position;
        bytes32 symbol;
        uint amount;
        uint price;
    }

    uint public orderId;

    mapping(bytes32 => mapping(uint => Order[])) public orderBook;

    function getOrderBook(
        bytes32 symbol,
        Position position
    ) public view returns (Order[] memory) {
        return orderBook[symbol][uint(position)];
    }

    function createLimitOrder(
        Position position,
        bytes32 symbol,
        uint amount,
        uint price
    ) public {
        if (position == Position.Buy)
            require(balances[msg.sender]["ETH"] >= amount * price);
        else if (position == Position.Sell)
            require(balances[msg.sender][symbol] >= amount);

        Order[] storage orders = orderBook[symbol][uint(position)];
        orders.push(
            Order(orderId, msg.sender, position, symbol, amount, price)
        );

        // Bubble sort
        if (position == Position.Buy) {
            for (uint i = orders.length - 1; i > 0; i--) {
                if (orders[i - 1].price > orders[i].price) break;

                Order memory _orders = orders[i - 1];
                orders[i - 1] = orders[i];
                orders[i] = _orders;
            }
        } else if (position == Position.Sell) {
            for (uint i = orders.length - 1; i > 0; i--) {
                if (orders[i - 1].price < orders[i].price) break;

                Order memory _orders = orders[i - 1];
                orders[i - 1] = orders[i];
                orders[i] = _orders;
            }
        }

        orderId++;
    }
}
