# 1. Overview

## What RealFi is

RealFi issues two tokens on Ethereum:

- **USDrf**, a dollar token minted 1:1 for USDC and redeemed 1:1 for USDC.
- **sUSDrf**, staked USDrf. It earns RealFi's yield, and leaving it takes a 7-day cooldown.

On chain, sUSDrf's cooldown reads 604,800 seconds (7 days), and 1 sUSDrf is worth 1.264 USDrf.[^realfi]

## What AlphaGrowth built around it

| Piece | What it does | Status |
|---|---|---|
| Euler lending markets | Lend USDC and USDrf against USDrf and sUSDrf, in two Euler clusters | Live since 2026-11-20, all five vaults switched on |
| Loop vault (Build 1) | Takes USDC, mints and stakes it, and borrows on Euler to hold about 3x sUSDrf | Built and tested; not on mainnet |
| Pool hooks (Build 2) | Two Uniswap v4 pools, USDrf/USDC and sUSDrf/USDrf, whose LP money is lent out between swaps | Built and tested; not on mainnet |
| Liquidator (Build 3) | Liquidates unhealthy loans in our markets in one transaction | Built and tested; not on mainnet |
| EulerSwap pools | Six pools that buy USDrf or sUSDrf and pay with a loan from our Euler vaults | Proposed; tested on a mainnet fork |
| Fynd | A route finder that sends each trade through whichever pools pay most, reached over an HTTP API | Proposed; Propeller Heads hosts it, and anyone can run their own ([09](09-routing-fynd.md#the-fynd-api)) |

## Why lenders fund the pools

The Build 2 pools need LPs to put money in, and few have. A pool that holds no money cannot pay a seller.

An EulerSwap pool trades from an Euler account instead of a token balance. When someone sells it USDrf, it deposits the
USDrf as collateral and borrows USDC from our Euler USDC vault to pay them. The pool's depth is whatever that vault can
lend, so we court lenders, who are paid the borrow rate, instead of LPs.

RealFi's own exits then repay the loan:

- USDrf is redeemed 1:1 for USDC.
- sUSDrf is unstaked to USDrf after its cooldown.

## Who uses it

Anyone who needs to move between USDC, USDrf and sUSDrf, in any direction: traders, the loop vault when it unwinds, and
liquidators who seize sUSDrf and need USDrf or USDC to repay a loan. Fynd sends each trade to the pools that pay most,
and splits it across several when one is not deep enough.

[^realfi]: sUSDrf `0x8f4507d315acf966Fe21F9f4feE4F7e1A6d4c400`: `cooldown()` = 604800 and `convertToAssets(1e6)` = 1,264,048, block 26,496,053.
