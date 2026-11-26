# 1. Overview

## What AlphaGrowth built

| Piece | What it does | Status |
|---|---|---|
| Euler RealFi Cluster | Borrowable USDC & USDrf against USDrf and sUSDrf collateral | Live on Mainnet. |
| Loop vault (Build 1) | Takes USDC, mints and stakes to 3x sUSDrf | Built and tested. |
| Pool hooks (Build 2) | Two Uniswap v4 Rehypothecation pools, USDrf/USDC and sUSDrf/USDrf.| Built and tested on OpenZeppelin Hooks. |
| Liquidator (Build 3) | Self-funded through RealFi's instant unstake, in one transaction; sUSDrf collateral against USDrf debt | Built and tested. |
| EulerSwap pools | Six borrow-to-fill pools, three per cluster: USDrf to USDC, sUSDrf to USDC, sUSDrf to USDrf | Tested on a mainnet fork. |
| Fynd | Splits each trade across the pools; hosted by Propeller Heads or self-run ([09](09-routing-fynd.md)) | Proposed. |

## Why borrow-to-fill

The Build 2 pools depend on LP deposits, and few have come. An EulerSwap pool instead borrows the output token from our
Euler vaults against the token it buys, so its depth is what lenders supply. RealFi's redemption and unstaking repay the
loans.
