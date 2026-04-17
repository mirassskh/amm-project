// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/LendingPool.sol";

contract LendingTest is Test {
    MyToken token;
    LendingPool pool;
    address user = address(1);

    function setUp() public {
        token = new MyToken();
        pool = new LendingPool(address(token));
        token.mint(user, 1000);
        vm.startPrank(user);
        token.approve(address(pool), 1000);
        vm.stopPrank();
    }

    function testDeposit() public {
        vm.prank(user);
        pool.deposit(500);
        assertEq(pool.deposited(user), 500);
    }

    function testBorrow() public {
        vm.startPrank(user);
        pool.deposit(500);
        pool.borrow(300);
        assertEq(pool.borrowed(user), 300);
        vm.stopPrank();
    }

    function testBorrowExceed() public {
        vm.startPrank(user);
        pool.deposit(500);
        vm.expectRevert();
        pool.borrow(400);
        vm.stopPrank();
    }

    function testRepay() public {
        vm.startPrank(user);
        pool.deposit(500);
        pool.borrow(200);
        pool.repay(200);
        assertEq(pool.borrowed(user), 0);
        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(user);
        pool.deposit(500);
        pool.withdraw(200);
        assertEq(pool.deposited(user), 300);
        vm.stopPrank();
    }

    function testLiquidation() public {
        address liquidator = address(2);
        token.mint(liquidator, 1000);

        vm.startPrank(user);
        pool.deposit(500);
        pool.borrow(300);
        vm.stopPrank();

        // 🔥 Делаем позицию нездоровой через vm.store
        // borrowed[user] хранится в slot 1, ключ = keccak256(user . slot)
        bytes32 borrowedSlot = keccak256(abi.encode(user, uint256(1)));
        vm.store(address(pool), borrowedSlot, bytes32(uint256(450))); // 450 > 375 (75% от 500)

        vm.prank(liquidator);
        pool.liquidate(user);

        assertEq(pool.deposited(user), 0);
    }
}