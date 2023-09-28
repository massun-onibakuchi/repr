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
}
