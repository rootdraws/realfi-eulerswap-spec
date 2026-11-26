# 10. Mainnet fork test

Hardhat fork of Ethereum at block 26,495,709 (2026-11-25). Scripts in [`sources/fork/`](sources/fork/), commands in its
README; each refuses a non-fork node.

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
| Sell 800k sUSDrf, split RealFi and RWA, one call | 1,008,667 USDC; 504,334 borrowed per pool |
| Buy with 400k USDC, split, one call | 315,350 sUSDrf; each pool's loan down 200,000 |

An earlier run tested one-way USDrf to USDC pools: 700k into one pool reverted on the supply cap, and the same 700k split
across both clusters filled.

Deviations from live config: profit receiver set to the Safe; deploy check accepts eUSDrf-2's 15% max discount (Fabio's
check expects 5%); balances written to storage.

Fabio's suites (unit, fork, fuzz, invariant, Sepolia conformance): `RealFiStructures/README.md`; property to test map in
`AUDIT-NOTES.md`.
