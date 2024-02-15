// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import "@uniswap/v3-periphery/contracts/libraries/LiquidityAmounts.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import "@uniswap/v3-periphery/contracts/libraries/LiquidityAmounts.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";

import {console} from "forge-std/Test.sol";
import "forge-std/console2.sol";

contract WETHAmountCalculator {
    IUniswapV3Pool public pool;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    mapping(uint256 => uint256) public token0Amounts;

    constructor(address _factory, address _WETH, address _USDT) {
        address poolAddress = IUniswapV3Factory(_factory).getPool(_WETH, _USDT, 3000); // Assuming a fee tier of 0.3%
        require(poolAddress != address(0), "Pool does not exist");

        pool = IUniswapV3Pool(poolAddress);
    }

    function getPrice(int24 tick, bool isWeth) public pure returns (uint256 priceU18) {
        priceU18 = OracleLibrary.getQuoteAtTick(
            tick,
            1e18, // fixed point to 18 decimals
            isWeth ? address(0) : address(1), // since we want the price in terms of token1/token0
            isWeth ? address(1) : address(0)
        );
    }

    function getTickAtSqrtRatio(uint160 sqrtPriceX96) external pure returns (int24 tick) {
        return TickMath.getTickAtSqrtRatio(sqrtPriceX96);
    }

    function getSlippageMaxWethAmount() external returns (uint256 maxWethAmount) {
        (uint160 sqrtPriceX96, int24 tick,,,,,) = pool.slot0();
        uint256 wethPrice = getPrice(
            tick,
            true // isWeth
        );
        console.log("current WETH price: %d", wethPrice);
        console.log("lowerTick");
        console.logInt(tick);

        uint160 sqrtPriceX96WithSlippage = calculateNewSqrtPriceX96(sqrtPriceX96);

        uint256 wethPriceWithSlippage = getPrice(
            TickMath.getTickAtSqrtRatio(sqrtPriceX96WithSlippage),
            true // isWeth
        );

        console.log("WETH price with slippage: %d", wethPriceWithSlippage);

        int24 lowerTick = TickMath.getTickAtSqrtRatio(sqrtPriceX96WithSlippage);
        console.log("lowerTick");
        console.logInt(lowerTick);

        int24 diff = lowerTick - tick;
        console.log("diff");
        console.logInt(diff);

        uint256 token0Amount = getTokensAmountBetweenTwoTicks(tick, lowerTick);

        return token0Amount;
    }

    // Example helper function to get liquidity for the tick range
    // This is a placeholder. Actual implementation will vary based on your contract's design

    function calculateNewSqrtPriceX96(uint160 currentSqrtPriceX96) public view returns (uint160) {
        uint256 multiplier = 95000000; // Equivalent to 0.95 in fixed-point with 6 decimals for precision
        uint256 scaleFactor = 100000000; // Scale factor to match the multiplier's precision

        uint256 currentPrice256 = uint256(currentSqrtPriceX96) * uint256(currentSqrtPriceX96);
        // console.log("currentPrice256: %d", currentPrice256);

        uint256 newSqrtPricePow2 = currentPrice256 * multiplier / scaleFactor;
        // console.log("newSqrtPricePow2: %d", newSqrtPricePow2);

        uint256 newSqrtPriceX96 = sqrt(newSqrtPricePow2);
        // console.log("newSqrtPriceX96: %d", newSqrtPriceX96);
        // console.log("uint160(newSqrtPriceX96): %d", uint160(newSqrtPriceX96));

        return uint160(newSqrtPriceX96);
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function getMaxWethSwap() external returns (uint256) {
        int24 tickSpacing = 60; //pool.tickSpacing();
        // console.log("tick spacing");
        // console.logInt(tickSpacing);

        (, int24 tick,,,,,) = pool.slot0();

        // console.log("lowerTick");
        // console.logInt(tick);

        uint256 wethPrice = getPrice(
            tick,
            true // isWeth
        );
        // console.log("current WETH price: %d", wethPrice);

        uint256 wethPriceWithSlippage = wethPrice * 95 / 100;
        // console.log("WETH price with slippage: %d", wethPriceWithSlippage);

        int24 tickRounded = tick - tick % tickSpacing;

        // console.log("tickRounded");
        // console.logInt(int256(tickRounded));

        uint256 totalWethAmount = 0;
        uint256 totalUsdtAmount = 0;
        uint256 totalWethPrice = wethPrice;

        while (totalWethPrice > wethPriceWithSlippage) {
            uint160 sqrtPriceX96Lower = TickMath.getSqrtRatioAtTick(tickRounded);
            // console.log("SqrtPriceX96Lower: %d", sqrtPriceX96Lower);

            // while (count > 1) {
            (uint128 liquidityGross, int128 liquidityNet,,,,,, bool initialized) = pool.ticks(tickRounded);
            // console.log("liquidityGross");
            // console.logInt(liquidityGross);

            // console.log("liquidityGross");
            // console.logInt(liquidityGross);
            // if (initialized) {
            //     liquidity += liquidityGross;
            // }

            int24 nextTick = tickRounded - tickSpacing;
            // console.log("next tick");
            // console.logInt(nextTick);

            uint160 sqrtPriceX96Upper = TickMath.getSqrtRatioAtTick(nextTick);
            // console.log("SqrtPriceX96Upper: %d", sqrtPriceX96Upper);

            // Calculate the amount of token0 in the range
            uint256 token0Amount =
                LiquidityAmounts.getAmount0ForLiquidity(sqrtPriceX96Lower, sqrtPriceX96Upper, liquidityGross);
            uint256 token1Amount =
                LiquidityAmounts.getAmount1ForLiquidity(sqrtPriceX96Lower, sqrtPriceX96Upper, liquidityGross);

            totalWethAmount += token0Amount;
            totalUsdtAmount += token1Amount;

            // console.log("totalWethAmount: %d", token0Amount);
            // console.log("totalUsdtAmount: %d", token1Amount);

            totalWethPrice = totalUsdtAmount * 1e18 / totalWethAmount;
            // console.log("totalWethPrice: %d", totalWethPrice);
            tickRounded = tickRounded - tickSpacing;
            // console.log("next tick");
            // console.logInt(tickRounded);

            // console.log("get price result");
            // console.log(getPrice(tickRounded, true));

            // break;
        }

        return totalWethAmount;
    }

    function getTokensAmountBetweenTwoTicks(int24 upperTick, int24 lowerTick)
        public
        view
        returns (uint256 token0Amount)
    {
        int24 tickSpacing = pool.tickSpacing();

        int24 tickRounded = upperTick - (upperTick % tickSpacing);
        console.log("LowerTickRounded");
        console.logInt(int256(tickRounded));

        // int24 upperTickRounded = upperTick - (upperTick % tickSpacing);
        // console.log("UpperTickRounded");
        // console.logInt(int256(upperTickRounded));

        // Get the sqrtPriceX96 for each tick
        uint160 sqrtPriceX96Lower = TickMath.getSqrtRatioAtTick(tickRounded);
        console.log("SqrtPriceX96Lower: %d", sqrtPriceX96Lower);
        uint160 sqrtPriceX96Upper = TickMath.getSqrtRatioAtTick(lowerTick);
        console.log("SqrtPriceX96Upper: %d", sqrtPriceX96Upper);

        // uint128 liquidity = getLiquidityForRange(tickRounded, lowerTick);

        uint128 liquidity = 0;
        uint256 totalToken0Amount = 0;
        uint256 totalToken1Amount = 0;

        for (int24 tick = upperTick; tick > lowerTick; tick -= tickSpacing) {
            (uint128 liquidityGross,,,,,,, bool initialized) = pool.ticks(tick);

            // console.log("liquidityGross");
            // console.logInt(liquidityGross);
            if (initialized) {
                // Assuming positive liquidityNet adds to the range and negative reduces
                // This is a simplification; actual calculation may need to consider more factors
                // liquidity += uint128(liquidityNet > 0 ? liquidityNet : -liquidityNet);
                liquidity += liquidityGross;
            }

            console.log("Liquidity between ticks: %d", liquidity);

            // Calculate the amount of token0 in the range
            uint256 token0Amount =
                LiquidityAmounts.getAmount0ForLiquidity(sqrtPriceX96Lower, sqrtPriceX96Upper, liquidity);
            uint256 token1Amount =
                LiquidityAmounts.getAmount1ForLiquidity(sqrtPriceX96Lower, sqrtPriceX96Upper, liquidity);

            totalToken0Amount += token0Amount;
            totalToken1Amount += token1Amount;

            uint256 finalWethPrice = totalToken1Amount * 10e18 / totalToken0Amount;
            console.log("finalWethPrice: %d", finalWethPrice);
        }

        return token0Amount;
    }

    function getLiquidityForRange(int24 upperTick, int24 lowerTick) private view returns (uint128) {
        uint128 liquidity = 0;
        int24 tickSpacing = pool.tickSpacing();

        // Iterate through the tick range, adjusting for tick spacing
        for (int24 tick = upperTick; tick > lowerTick; tick -= tickSpacing) {
            (uint128 liquidityGross, int128 liquidityNet,,,,,, bool initialized) = pool.ticks(tick);
            // console.log("liquidityNet");
            // console.logInt(liquidityNet);
            // console.log("liquidityGross");
            // console.logInt(liquidityGross);
            if (initialized) {
                // Assuming positive liquidityNet adds to the range and negative reduces
                // This is a simplification; actual calculation may need to consider more factors
                // liquidity += uint128(liquidityNet > 0 ? liquidityNet : -liquidityNet);
                liquidity += liquidityGross;
            }
        }
        return liquidity;
    }

    function getLiquidityLoop(uint256 loops) external returns (uint128) {
        uint128 liquidity = 0;
        int24 tickSpacing = pool.tickSpacing();
        (, int24 tick,,,,,) = pool.slot0();

        // Iterate through the tick range, adjusting for tick spacing
        for (uint256 i = 0; i < loops; i++) {
            tick -= tickSpacing;
            (uint128 liquidityGross, int128 liquidityNet,,,,,, bool initialized) = pool.ticks(tick);
            // uint256 price = getPrice(tick, true);
            // console.log("price: %d", price);
            // console.log("liquidityNet");
            // console.logInt(liquidityNet);
            // console.log("liquidityGross");
            // console.logInt(liquidityGross);
            if (initialized) {
                // Assuming positive liquidityNet adds to the range and negative reduces
                // This is a simplification; actual calculation may need to consider more factors
                // liquidity += uint128(liquidityNet > 0 ? liquidityNet : -liquidityNet);
                liquidity += liquidityGross;
            }
        }
        token0Amounts[uint256(tick)] = liquidity;
        return liquidity;
    }

    function getUSDTAmountForWETH(uint256 wethAmount) external returns (uint256 usdtAmount) {
        // Simulate the swap from WETH to USDT
        try IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6).quoteExactInputSingle(WETH, USDT, 3000, wethAmount, 0)
        returns (uint256 amount) {
            return amount;
        } catch {
            // Handle the case where the quote fails (e.g., liquidity issues)
            revert("Failed to get quote");
        }
    }
}
