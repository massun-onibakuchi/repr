// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
import {ApproxParams} from "../interfaces/ApproxParams.sol";
import {PoolMath, PoolState, PoolPreCompute} from "./PoolMath.sol";
import {Errors} from "./Errors.sol";

library LibApproximation {
    using SignedMath for int256;

    // The error function computes the difference between the desired and actual proportions
    // of token0 and token1 after performing a swap.
    // The goal is to make this difference as close to zero as possible.
    function error_function(
        uint256 baseLptSwap,
        PoolState memory state,
        PoolPreCompute memory comp,
        uint256 baseLptDeposit
    ) internal pure returns (int256) {
        // Compute the amount of token1 received after swapping delta0 amount of token0
        (int256 netUnderlying18,,) = PoolMath.calculateSwap(state, comp, -int256(baseLptSwap * 3));
        uint256 uIn = uint256(netUnderlying18);
        // Calculate the proportionality condition after the swap:
        // The left side represents the ratio of token1 to token0 in the pool after the swap.
        // The right side represents the ratio of token1 to token0 being added to the pool.
        uint256 scaleFactor = 1e18;
        uint256 left_side = scaleFactor * (state.totalUnderlying18 - uIn) / (state.totalBaseLptTimesN + baseLptSwap);
        uint256 right_side = scaleFactor * uIn / (baseLptDeposit - baseLptSwap);

        return int256(left_side) - int256(right_side);
    }

    // The find_swap_amount function uses the bisection method to find the value of delta0
    // that satisfies the proportionality condition.
    // It repeatedly narrows down an interval [a, b] based on the value of the error function
    // at the midpoint until the error is close to zero or the interval is sufficiently small.
    function findSwapBaseLptSwap(PoolState memory state, uint256 baseLptDeposit, ApproxParams memory approx)
        internal
        view
        returns (uint256 baseLptSwap)
    {
        // @todo custom initial guess/interval [a, b]
        uint256 a = 0;
        uint256 b = state.totalBaseLptTimesN; // Maximum possible value for delta0 is totalIn0
        uint256 midpoint;
        int256 error_mid;

        PoolPreCompute memory comp = PoolMath.computeAmmParameters(state);

        // Continue until the interval is sufficiently small or maxIteration is reached
        for (uint256 i = 0; i < approx.maxIteration; i++) {
            midpoint = (a + b) / 2; // Calculate the midpoint of the current interval
            error_mid = error_function(midpoint, state, comp, baseLptDeposit);

            // Check if the absolute error is less than the tolerance
            if (error_mid.abs() < approx.eps) {
                return midpoint;
            }

            // Adjust the interval based on the sign of the error
            if (error_mid > 0) {
                a = midpoint;
            } else {
                b = midpoint;
            }
        }

        // If the function hasn't returned by now, it means it didn't converge within the tolerance range
        revert Errors.ApproxFail();
    }
}
