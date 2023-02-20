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
        address tokenAddress;
        uint amount;
        uint price;
        uint filled;
    }

    uint public orderId;

    mapping(address => mapping(uint => Order[])) public orderBook;

    function getOrderBook(
        address tokenAddress,
        Position position
    ) public view returns (Order[] memory) {
        return orderBook[tokenAddress][uint(position)];
    }

    function createLimitOrder(
        Position position,
        address tokenAddress,
        uint amount,
        uint price
    ) public {
        if (position == Position.Buy)
            require(ethBalance[msg.sender] >= amount * price);
        else if (position == Position.Sell)
            require(balances[msg.sender][tokenAddress] >= amount);

        Order[] storage orders = orderBook[tokenAddress][uint(position)];
        orders.push(
            Order(orderId, msg.sender, position, tokenAddress, amount, price, 0)
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

    function createMarketOrder(
        Position position,
        address tokenAddress,
        uint amount
    ) public {
        if (position == Position.Sell)
            require(
                balances[msg.sender][tokenAddress] >= amount,
                "insufficient balance"
            );

        Order[] storage orders = orderBook[tokenAddress][
            position == Position.Buy ? 1 : 0
        ];

        uint totalFilled = 0;

        for (uint i = 0; i < orders.length && totalFilled < amount; i++) {
            uint toFill = amount - totalFilled;
            uint availableToFill = orders[i].amount - orders[i].filled;
            uint filled = 0;

            if (availableToFill > toFill) filled = toFill;
            else filled = availableToFill;

            totalFilled += filled;
            orders[i].filled += filled;
            uint cost = filled * orders[i].price;

            if (position == Position.Buy) {
                // if msg.sender is the seller
                require(ethBalance[msg.sender] >= cost);

                balances[msg.sender][tokenAddress] += filled;
                ethBalance[msg.sender] -= cost;

                balances[orders[i].trader][tokenAddress] -= filled;
                ethBalance[orders[i].trader] += cost;
            } else if (position == Position.Sell) {
                // if msg.sender is the buyer
                balances[msg.sender][tokenAddress] -= filled;
                ethBalance[msg.sender] += cost;

                balances[orders[i].trader][tokenAddress] += filled;
                ethBalance[orders[i].trader] -= cost;
            }
        }

        while (orders.length > 0 && orders[0].filled == orders[0].amount) {
            for (uint i = 0; i < orders.length - 1; i++) {
                orders[i] = orders[i + 1];
            }
            orders.pop();
        }
    }
}
