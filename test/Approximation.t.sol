// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
import {PoolMath, PoolState, PoolPreCompute} from "src/libs/PoolMath.sol";
import {ApproxParams} from "src/interfaces/ApproxParams.sol";
import {LibApproximation} from "src/libs/LibApproximation.sol";

contract ApproxSwapPtToAddLiquidityUnitTest is Test {
    using SignedMath for int256;

    PoolState state;
    PoolPreCompute comp;

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
    }

    function test_error_function(uint256 baseLptSwap) public virtual {
        uint256 baseLptDeposit = 100 * 1e18;
        vm.assume(baseLptSwap < baseLptDeposit);

        int256 delta = LibApproximation.error_function(baseLptSwap, state, comp, baseLptDeposit);

        assert(delta.abs() > 0.00000001 * 1e18);
    }
}
