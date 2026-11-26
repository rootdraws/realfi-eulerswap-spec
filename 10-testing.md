# 10. Mainnet fork test

The test ran on a Hardhat fork of Ethereum at block 26,495,709 (2026-11-25). The scripts and commands are in
[`sources/fork/`](sources/fork/), and each script refuses to run on anything but the fork.

| Step | Script | Result |
|---|---|---|
| Builds 1 to 3 | `deploy --env mainnet-fork --impersonate-deployer` | Done |
| RealFi listings | `realfi-list.sh` | Done |
| RWA Safe batch | `safe-batch.sh` | Done |
| Lenders and pool stock | `load.sh` | 7.5M USDC, 3M USDrf; 100k sUSDrf per pool |
| Pools | `script/Pools.s.sol` | Four deployed |
| Split trade | `split-swap.sh` | See below |

| Test | Result |
|---|---|
| Quote 100k sUSDrf to USDC, and to USDrf, each pool | 126,083 |
| Quote 50k USDC or USDrf to sUSDrf, each pool | 39,419 sUSDrf |
| Sell 800k sUSDrf, split RealFi and RWA, one call | 1,008,667 USDC against 1,011,702 fair value: 0.30% cost, all fee; 504,334 borrowed per pool |
| Buy with 400k USDC, split, one call | 315,350 sUSDrf; each pool's loan down 200,000 |

An earlier run tested one-way USDrf to USDC pools: 700k into one pool reverted on the supply cap, and the same 700k split
across both clusters filled.

The fork differs from the live setup in three ways:

- The profit receiver is set to the Safe.
- The deploy check accepts eUSDrf-2's 15% maximum discount, where the deploy check expects 5%.
- Token balances were written straight into storage.

The unit, fork, fuzz, invariant and Sepolia conformance suites are listed in `RealFiStructures/README.md`. The map
from each property to its test is in [`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md).
