# 10. Mainnet fork test

We forked Ethereum mainnet, deployed everything, and traded through the pools. Anyone with an archive RPC can rerun it
with one script; [`sources/fork/README.md`](sources/fork/README.md) has the steps.

## Setup

1. Deployed Builds 1 to 3 with the RealFiStructures deploy engine.
2. Added RealFi's listings.
3. Deposited 7.5M USDC and 3M USDrf as lenders, and gave each pool 100k sUSDrf.
4. Deployed the four EulerSwap pools.

## Results

These results come from the run at block 26,495,709 on 2026-11-25.

| Trade | Result |
|---|---|
| Sell 100k sUSDrf into one pool | 126,083 USDC or USDrf |
| Buy sUSDrf with 50k USDC or USDrf from one pool | 39,419 sUSDrf |
| Sell 800k sUSDrf, split across the RealFi and RWA pools in one transaction | 1,008,667 USDC, a 0.30% cost (the fee) against 1,011,702 fair value |
| Buy sUSDrf with 400k USDC, split the same way | 315,350 sUSDrf; each pool's loan fell by 200,000 USDC |

## Differences from mainnet

- The test gave lenders, pools and traders their USDC, USDrf and sUSDrf by writing balances directly into the fork, not
  by buying or minting them.
- The liquidator sends its profit to an address that is not chosen for mainnet yet. The fork used the AlphaGrowth Safe,
  `0x4f894Bfc9481110278C356adE1473eBe2127Fd3C`, in its place.
- The deploy script expects eUSDrf-2's liquidation bonus to be capped at 5%, but the live vault caps it at 15%. The fork
  raised the script's limit to 15% to match the live vault.

The RealFiStructures unit, fork, fuzz, invariant and Sepolia suites are listed in its README, and
[`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md) maps each property to its test.
