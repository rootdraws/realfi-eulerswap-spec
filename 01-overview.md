# 1. Overview

## What AlphaGrowth built

| Piece | What it does | Status |
|---|---|---|
| Euler RealFi Cluster | Borrowable USDC & USDrf against USDrf and sUSDrf collateral | Live on Mainnet. |
| Loop vault (Build 1) | Takes USDC, mints and stakes to 3x sUSDrf | Built and tested. |
| Pool hooks (Build 2) | Two Uniswap v4 Rehypothecation pools, USDrf/USDC and sUSDrf/USDrf.| Built and tested on OpenZeppelin Hooks. |
| Liquidator (Build 3) | Self-funded through RealFi's instant unstake, in one transaction; sUSDrf collateral against USDrf debt | Built and tested. |
| EulerSwap pools | Four borrow-to-fill pools: sUSDrf <> USDC and sUSDrf <> USDrf in each cluster. | Tested on a mainnet fork. |
| Fynd | Splits each trade across the pools; hosted by Propeller Heads or self-run ([09](09-routing-fynd.md)) | API usage Proposed for any internal trades / arbitrage. |

## Why borrow-to-fill

- **Debt swaps:** the pools fill sUSDrf <> USDC and sUSDrf <> USDrf by borrowing, alongside the Rehypothecation pools and
  the instant redemption vault.
- **Depth:** idle USDC in the RealFi cluster or the AlphaGrowth RWA cluster backs every sale of sUSDrf into USDC.
- **Large orders:** Fynd splits an order across the pools in one Uniswap v4 transaction.
- **Yield and unwind:** the pools' sUSDrf keeps earning while held. The loans clear when USDC buyers take that sUSDrf,
  which a looping flow supplies.
