// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MyToken.sol";

contract LendingPool {
    MyToken public token;

    mapping(address => uint) public deposited;
    mapping(address => uint) public borrowed;

    uint public constant LTV = 75; // 75%

    constructor(address _token) {
        token = MyToken(_token);
    }

    function deposit(uint amount) public {
        token.transferFrom(msg.sender, address(this), amount);
        deposited[msg.sender] += amount;
    }

    function borrow(uint amount) public {
        uint maxBorrow = (deposited[msg.sender] * LTV) / 100;
        require(borrowed[msg.sender] + amount <= maxBorrow, "LTV exceeded");
        borrowed[msg.sender] += amount;
        token.transfer(msg.sender, amount);
    }

    function repay(uint amount) public {
        token.transferFrom(msg.sender, address(this), amount);
        borrowed[msg.sender] -= amount;
    }

    function withdraw(uint amount) public {
        require(deposited[msg.sender] >= amount, "not enough");
        uint maxBorrow = ((deposited[msg.sender] - amount) * LTV) / 100;
        require(borrowed[msg.sender] <= maxBorrow, "health < 1");
        deposited[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

    function liquidate(address user) public {
        uint maxBorrow = (deposited[user] * LTV) / 100;
        require(borrowed[user] > maxBorrow, "healthy"); // ✅ Исправлено: > вместо >=
        uint collateral = deposited[user];
        deposited[user] = 0;
        borrowed[user] = 0;
        token.transfer(msg.sender, collateral);
    }
}