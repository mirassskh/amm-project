// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/AMM.sol";

contract AMMTest is Test {
    MyToken A;
    MyToken B;
    AMM amm;

    address user = address(1);

    function setUp() public {
        A = new MyToken();
        B = new MyToken();
        amm = new AMM(address(A), address(B));

        A.mint(user, 1000);
        B.mint(user, 1000);

        vm.startPrank(user);
        A.approve(address(amm), 1000);
        B.approve(address(amm), 1000);
        vm.stopPrank();
    }

    function testAddLiquidity() public {
        vm.prank(user);
        amm.addLiquidity(500, 500);

        assertEq(amm.reserveA(), 500);
        assertEq(amm.reserveB(), 500);
    }

    function testRemoveLiquidity() public {
        vm.startPrank(user);
        amm.addLiquidity(500, 500);
        uint lp = amm.lpToken().balanceOf(user);

        amm.removeLiquidity(lp);

        assertEq(A.balanceOf(user), 1000);
        vm.stopPrank();
    }

    function testSwap() public {
        vm.startPrank(user);
        amm.addLiquidity(500, 500);
        amm.swapAforB(100, 1);
        vm.stopPrank();
    }

    function testSlippage() public {
        vm.startPrank(user);
        amm.addLiquidity(500, 500);

        vm.expectRevert();
        amm.swapAforB(100, 1000);
        vm.stopPrank();
    }

    function testLargeSwap() public {
        vm.startPrank(user);
        amm.addLiquidity(500, 500);
        amm.swapAforB(400, 1);
        vm.stopPrank();
    }

    function testZeroLiquidity() public {
        vm.expectRevert();
        amm.swapAforB(100, 1);
    }

    function testMultipleUsers() public {
        address u2 = address(2);
        A.mint(u2, 1000);
        B.mint(u2, 1000);

        vm.startPrank(user);
        amm.addLiquidity(500, 500);
        vm.stopPrank();

        vm.startPrank(u2);
        A.approve(address(amm), 1000);
        B.approve(address(amm), 1000);
        amm.addLiquidity(500, 500);
        vm.stopPrank();

        assertEq(amm.reserveA(), 1000);
    }

    // FUZZ
    function testFuzzSwap(uint amount) public {
        vm.assume(amount > 1 && amount < 500);

        vm.startPrank(user);
        amm.addLiquidity(500, 500);

        uint out = amm.getAmountOut(amount, 500, 500);
        if (out == 0) return;

        amm.swapAforB(amount, 1);
        vm.stopPrank();
    }
    function testGetAmountOut() public {
    uint out = amm.getAmountOut(100, 500, 500);
    assertGt(out, 0);
}
function testLPTokenMint() public {
    vm.startPrank(user);

    amm.addLiquidity(500, 500);

    uint lp = amm.lpToken().balanceOf(user);
    assertGt(lp, 0);

    vm.stopPrank();
}
}