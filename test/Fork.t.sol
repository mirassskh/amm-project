// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address) external view returns (uint);
}

interface IUniswapV2Router {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

contract ForkTest is Test {
    address constant USDC   = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH   = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"));
    }

    function testUSDCtotalSupply() public {
        uint supply = IERC20(USDC).totalSupply();
        assertGt(supply, 0);
    }

    function testUniswapSwap() public {
        address user = address(1);
        vm.deal(user, 1 ether);
        vm.startPrank(user);

        address[] memory path = new address[](2);  // ← исправлено
        path[0] = WETH;
        path[1] = USDC;

        uint beforeBalance = IERC20(USDC).balanceOf(user);

        IUniswapV2Router(ROUTER).swapExactETHForTokens{value: 0.1 ether}(
            1,
            path,
            user,
            block.timestamp
        );

        uint afterBalance = IERC20(USDC).balanceOf(user);
        assertGt(afterBalance, beforeBalance);

        vm.stopPrank();
    }
}