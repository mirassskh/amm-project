// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/AMM.sol";

contract InvariantTest is Test {
    MyToken A;
    MyToken B;
    AMM amm;

    function setUp() public {
        A = new MyToken();
        B = new MyToken();
        amm = new AMM(address(A), address(B));

        A.mint(address(this), 1000);
        B.mint(address(this), 1000);

        A.approve(address(amm), 1000);
        B.approve(address(amm), 1000);

        amm.addLiquidity(500, 500);
    }

    function invariant_K() public {
        uint k = amm.reserveA() * amm.reserveB();
        assertGt(k, 0);
    }
}