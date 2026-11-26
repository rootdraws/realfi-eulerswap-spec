# 1. Overview

## What AlphaGrowth built

| Piece | What it does | Status |
|---|---|---|
| Euler RealFi Cluster | Borrowable USDC & USDrf against USDrf and sUSDrf collateral | Live on Mainnet. |
| Loop vault (Build 1) | Takes USDC, mints and stakes to 3x sUSDrf | Built and tested. |
| Pool hooks (Build 2) | Two Uniswap v4 Rehypothecation pools, sUSDrf/USDC and sUSDrf/USDrf.| Built and tested on OpenZeppelin Hooks. |
| Liquidator (Build 3) | Self-funded through RealFi's instant unstake, in one transaction; sUSDrf collateral against USDrf debt | Built and tested. |
| EulerSwap pools | Four borrow-to-fill pools, two per cluster: sUSDrf <> USDC and sUSDrf <> USDrf. This allows Univ4 Flash Accounting between Eulerswap pools for larger orders, facilitated through Fynd Routing. | Tested on a mainnet fork. |
| Fynd | Splits each trade across the pools; hosted by Propeller Heads or self-run ([09](09-routing-fynd.md)) | API usage Proposed for any internal trades / arbitrage. |

## Why borrow-to-fill

An EulerSwap pool allows sUSDrf <> USDC trades and sUSDrf <> USDrf trades as debt swaps in addition to the Rehypothecation pools, and the instant redemption vault. The main advantage is that any USDC inside of the RealFi cluster, or the AlphaGrowth RWA cluster on Mainnet can be used to support trades into USDC.

The sUSDrf collateral can earn yield while the Eulerswap pool is composed of sUSDrf, but it is necessary for USDC buyers to want more sUSDrf -- which is achievable through a looping flow. 
