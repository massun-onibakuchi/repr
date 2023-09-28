// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

// import {LibApproximation} from "src/libs/LibApproximation.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
import {PoolMath, PoolState, PoolPreCompute} from "src/libs/PoolMath.sol";
import {ApproxParams} from "src/interfaces/ApproxParams.sol";

/// @dev Modified version of LibApproximation
library LibApproximation {
    // The error function computes the difference between the desired and actual proportions
    // of token0 and token1 after performing a swap.
    // The goal is to make this difference as close to zero as possible.
    function error_function(
        uint256 baseLptSwap,
        PoolState memory state,
        PoolPreCompute memory /* comp */,
        uint256 baseLptDeposit,
        uint256 netUnderlying18
    ) internal pure returns (int256) {
        // Compute the amount of token1 received after swapping delta0 amount of token0
        // Note: Use the pre-computed value instead of calling calculateSwap().
        // (int256 netUnderlying18,,) = PoolMath.calculateSwap(state, comp, -int256(baseLptSwap * 3));
        uint256 uIn = uint256(netUnderlying18);
        // Calculate the proportionality condition after the swap:
        // The left side represents the ratio of token1 to token0 in the pool after the swap.
        // The right side represents the ratio of token1 to token0 being added to the pool.
        uint256 scaleFactor = 1e18;
        uint256 left_side = scaleFactor * (state.totalUnderlying18 - uIn) / (state.totalBaseLptTimesN + baseLptSwap);
        uint256 right_side = scaleFactor * uIn / (baseLptDeposit - baseLptSwap);

        return int256(left_side) - int256(right_side);
    }
}

contract ApproxSwapPtToAddLiquidityUnitTest is Test {
    using SignedMath for int256;

    PoolState state;
    PoolPreCompute comp;
    uint256 baseLptSwap = 100 * 1e18;
    uint underlyingIn18;

    function setUp() public {
        vm.warp(18228389); // block.timestamp is not relevant; choose any arbitrary value

        state = PoolState({
            totalBaseLptTimesN: 3300 * 1e18,
            totalUnderlying18: 3000 * 1e18,
            maturity: block.timestamp + 100 days,
            scalarRoot: 1.2 * 1e18,
            lnFeeRateRoot: 0.001 * 1e18,
            protocolFeePercent: 10,
            lastLnImpliedRate: 0.1 * 1e18
        });

        comp = PoolMath.computeAmmParameters(state);
        (int256 netUnderlying18,,) = PoolMath.calculateSwap(state, comp, -int256(baseLptSwap * 3));
        underlyingIn18 = uint256(netUnderlying18);
    }

    function test_error_function_2(uint256 baseLptDeposit) public virtual {
        vm.assume(baseLptSwap < baseLptDeposit);

    int256 delta = LibApproximation.error_function(baseLptSwap, state, comp, baseLptDeposit, underlyingIn18);

        assert(delta.abs() > 0.00000001 * 1e18);
    }
}
