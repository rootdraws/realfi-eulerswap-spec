# 10. Mainnet fork test

We forked Ethereum at block 26,495,709 (2026-11-25), deployed everything, and traded through the pools. The scripts are
in [`sources/fork/`](sources/fork/) and refuse to run anywhere but the fork.

## Setup

1. Deployed Builds 1 to 3 with the RealFiStructures deploy engine.
2. Added RealFi's listings and ran the pending RWA Safe batch.
3. Deposited 7.5M USDC and 3M USDrf as lenders, and gave each pool 100k sUSDrf.
4. Deployed the four EulerSwap pools.

## Results

| Trade | Result |
|---|---|
| Sell 100k sUSDrf into one pool | 126,083 USDC or USDrf |
| Buy sUSDrf with 50k USDC or USDrf from one pool | 39,419 sUSDrf |
| Sell 800k sUSDrf, split across the RealFi and RWA pools in one transaction | 1,008,667 USDC, a 0.30% cost (the fee) against 1,011,702 fair value |
| Buy sUSDrf with 400k USDC, split the same way | 315,350 sUSDrf; each pool's loan fell by 200,000 USDC |

## Differences from mainnet

- Token balances were written directly into storage.
- The profit receiver is the Safe.
- The deploy check was set to accept eUSDrf-2's live 15% maximum liquidation discount; its default is 5%.

The RealFiStructures unit, fork, fuzz, invariant and Sepolia suites are listed in its README, and
[`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md) maps each property to its test.
