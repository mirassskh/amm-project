// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken t;

    function setUp() public {
        t = new MyToken();
    }

    function testMint() public {
        t.mint(address(this), 100);
        assertEq(t.balanceOf(address(this)), 100);
    }

    function testTransfer() public {
        t.mint(address(this), 100);
        t.transfer(address(1), 50);
        assertEq(t.balanceOf(address(1)), 50);
    }

    function testApprove() public {
        t.approve(address(1), 100);
        assertEq(t.allowance(address(this), address(1)), 100);
    }

    function testTransferFrom() public {
        t.mint(address(this), 100);
        t.approve(address(1), 100);

        vm.prank(address(1));
        t.transferFrom(address(this), address(2), 50);

        assertEq(t.balanceOf(address(2)), 50);
    }
}