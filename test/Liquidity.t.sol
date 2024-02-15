// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;
pragma abicoder v2;

import {Test, console} from "forge-std/Test.sol";
import {WETHAmountCalculator} from "../src/Liquidity.sol";

contract CounterTest is Test {
    WETHAmountCalculator public calculator;

    function setUp() public {
        calculator = new WETHAmountCalculator(
            address(0x1F98431c8aD98523631AE4a59f267346ea31F984),
            address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2),
            address(0xdAC17F958D2ee523a2206206994597C13D831ec7)
        );
    }

    // function test_liquidity() public {
    //     (uint256 token0Amount, uint256 token1Amount) = calculator.getToken0AmountBetweenTicks(100);
    //     console.log("token0Amount: %d", token0Amount);
    //     console.log("token1Amount: %d", token1Amount);
    // }

    // function test_priceToTick() public {
    //     int24 tick = calculator.getTickAtSqrtRatio(uint160(4154087104752403781318106));
    //     console.log("tick from price");
    //     console.logInt(tick);

    //     uint256 tokenPrice = calculator.calculatePriceFromSqrtPriceX96(4154087104752403781318106);
    //     console.log("token price");
    //     console.log(tokenPrice);
    // }

    // function test_calculateTickWithSlippage() public {
    //     uint256 priceWithSlippage = calculator.calculateNewSqrtPriceX96(4154087104752403781318106);
    //     int24 lowerTick = calculator.getTickAtSqrtRatio(uint160(4154087104752403781318106));
    //     int24 upperTick = calculator.getTickAtSqrtRatio(uint160(priceWithSlippage));
    //     console.log("tick with slippage");
    //     console.logInt(upperTick);

    //     uint256 tokenPrice = calculator.calculatePriceFromSqrtPriceX96(priceWithSlippage);
    //     console.log("token price with slippage");
    //     console.log(tokenPrice);

    //     (uint256 token0Amount, uint256 token1Amount) = calculator.getToken0AmountBetweenTwoTicks(lowerTick, upperTick);
    //     console.log("token0Amount: %d", token0Amount);
    //     console.log("token1Amount: %d", token1Amount);
    // }

    // function test_getSlippageMaxWethAmount() public {
    //     uint256 normalUsdtAmount = calculator.getUSDTAmountForWETH(1e18);
    //     console.log("queoted normalWethPrice: %d", normalUsdtAmount);

    //     uint256 maxWethAmount = calculator.getSlippageMaxWethAmount();
    //     console.log("maxWethAmount: %d", maxWethAmount);

    //     uint256 finalUsdtAmount = calculator.getUSDTAmountForWETH(maxWethAmount);
    //     console.log("final usdt: %d", finalUsdtAmount);

    //     uint256 finalWethPrice = finalUsdtAmount * 10e18 / maxWethAmount;

    //     console.log("finalWethPrice: %d", finalWethPrice);
    // }

    // function test_getMaxWethAmount() public {
    //     uint256 wethAmount = calculator.getMaxWethSwap();
    //     console.log("wethAmount: %d", wethAmount / 1e18);
    // }

    function test_calculateLoopGas() public {
        uint128 liquidity = calculator.getLiquidityLoop(20);
        console.log(liquidity);
    }
}
