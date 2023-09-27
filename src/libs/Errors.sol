// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

library Errors {
    // Approx
    error ApproxFail();
    error ApproxParamsInvalid(uint256 guessMin, uint256 guessMax, uint256 eps);
    error ApproxBinarySearchInputInvalid(
        uint256 approxGuessMin, uint256 approxGuessMax, uint256 minGuessMin, uint256 maxGuessMax
    );

    // Factory
    error FactoryPoolAlreadyExists();
    error FactoryUnderlyingMismatch();

    // Pool
    error PoolOnlyOwner();
    error PoolInvalidParamName();
    error PoolUnauthorizedCallback();
    error PoolInvalidIndex();
    error PoolInsufficientBaseLptReserve();
    error PoolExpired();
    error PoolZeroAmountsInput();
    error PoolZeroAmountsOutput();
    error PoolZeroLnImpliedRate();
    error PoolInsufficientBaseLptForTrade();
    error PoolInsufficientBaseLptReceived();
    error PoolInsufficientUnderlyingReceived();
    error PoolZeroTotalPtOrTotalAsset();
    error PoolExchangeRateBelowOne(int256 exchangeRate);
    error PoolProportionMustNotEqualOne();
    error PoolRateScalarZero();
    error PoolScalarRootBelowZero();
    error PoolProportionTooHigh();

    // Router
    error RouterOnlyOwner();
    error RouterInsufficientWETH();
    error RouterPoolNotFound();
    error RouterTransactionTooOld();
    error RouterInsufficientLpOut();
    error RouterInsufficientTokenBalance();
    error RouterInsufficientUnderlyingOut();
    error RouterInsufficientPtOut();
    error RouterInsufficientYtOut();
    error RouterInsufficientPYOut();
    error RouterInsufficientTokenOut();
    error RouterExceededLimitUnderlyingIn();
    error RouterExceededLimitPtIn();
    error RouterExceededLimitYtIn();
    error RouterInsufficientUnderlyingRepay();
    error RouterInsufficientPtRepay();
    error RouterNotAllUnderlyingUsed();

    error RouterCallbackNotNapierPool();

    // Generic
    error ZeroAddress();
    error FailedToSendEther();
    error NotWETH();

    // Config
    error LnFeeRateRootTooHigh();
    error ProtocolFeePercentTooHigh();
    error InitialAnchorTooLow();
}
