// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MyToken.sol";
import "./LPToken.sol";

contract AMM {
    MyToken public tokenA;
    MyToken public tokenB;
    LPToken public lpToken;

    uint public reserveA;
    uint public reserveB;

    event LiquidityAdded(address user, uint a, uint b);
    event LiquidityRemoved(address user, uint a, uint b);
    event Swap(address user, uint inAmount, uint outAmount);

    constructor(address a, address b) {
        tokenA = MyToken(a);
        tokenB = MyToken(b);
        lpToken = new LPToken();
    }

    function addLiquidity(uint a, uint b) public {
        require(a > 0 && b > 0, "zero");

        tokenA.transferFrom(msg.sender, address(this), a);
        tokenB.transferFrom(msg.sender, address(this), b);

        uint liquidity;
        if (lpToken.totalSupply() == 0) {
            liquidity = a;
        } else {
            liquidity = (a * lpToken.totalSupply()) / reserveA;
        }

        lpToken.mint(msg.sender, liquidity);

        reserveA += a;
        reserveB += b;

        emit LiquidityAdded(msg.sender, a, b);
    }

    function removeLiquidity(uint lp) public {
        uint total = lpToken.totalSupply();

        uint a = (lp * reserveA) / total;
        uint b = (lp * reserveB) / total;

        lpToken.burn(msg.sender, lp);

        reserveA -= a;
        reserveB -= b;

        tokenA.transfer(msg.sender, a);
        tokenB.transfer(msg.sender, b);

        emit LiquidityRemoved(msg.sender, a, b);
    }

    function getAmountOut(uint inAmount, uint rIn, uint rOut) public pure returns (uint) {
        uint inWithFee = (inAmount * 997) / 1000;
        return (inWithFee * rOut) / (rIn + inWithFee);
    }

    function swapAforB(uint amountIn, uint minOut) public {
        require(reserveA > 0 && reserveB > 0, "no liquidity");

        uint out = getAmountOut(amountIn, reserveA, reserveB);
        require(out >= minOut, "slippage");

        tokenA.transferFrom(msg.sender, address(this), amountIn);
        tokenB.transfer(msg.sender, out);

        reserveA += amountIn;
        reserveB -= out;

        emit Swap(msg.sender, amountIn, out);
    }
}