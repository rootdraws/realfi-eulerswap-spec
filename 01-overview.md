# 1. Overview

## What AlphaGrowth built

| Piece | What it does | Status |
|---|---|---|
| Euler RealFi Cluster | Borrowable USDC & USDrf against USDrf and sUSDrf collateral | Live on Mainnet. |
| Loop vault (Build 1) | Takes USDC, mints and stakes to 3x sUSDrf | Built and tested. |
| Pool hooks (Build 2) | Two Uniswap v4 Rehypothecation pools, USDrf/USDC and sUSDrf/USDrf.| Built and tested on OpenZeppelin Hooks. |
| Liquidator (Build 3) | Liquidates unhealthy loans in our markets in one transaction | Built and tested; not on mainnet |
| EulerSwap pools | Six pools that buy USDrf or sUSDrf and pay with a loan from our Euler vaults | Proposed; tested on a mainnet fork |
| Fynd | Routes each trade through whichever pools pay most | Proposed; hosted by Propeller Heads or self-run ([09](09-routing-fynd.md)) |

## Why lenders fund the pools

The Build 2 pools need LPs to put money in, and few have. A pool that holds no money cannot pay a seller.

An EulerSwap pool trades from an Euler account instead of a token balance. When someone sells it USDrf, it deposits the
USDrf as collateral and borrows USDC from our Euler USDC vault to pay them. The pool's depth is whatever that vault can
lend, so we court lenders, who are paid the borrow rate, instead of LPs.

RealFi's own exits then repay the loan:

- USDrf is redeemed 1:1 for USDC.
- sUSDrf is unstaked to USDrf after its cooldown.

Traders, the loop vault and liquidators all reach the pools through Fynd.

