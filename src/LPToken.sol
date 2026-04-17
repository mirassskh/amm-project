// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LPToken {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    function mint(address to, uint amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function burn(address from, uint amount) external {
        require(balanceOf[from] >= amount, "not enough");
        balanceOf[from] -= amount;
        totalSupply -= amount;
    }
}