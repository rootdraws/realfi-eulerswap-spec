# 10. Mainnet fork test

Hardhat fork of Ethereum at block 26,495,709 (2026-11-25). Scripts in [`sources/fork/`](sources/fork/), commands in its
README; each refuses a non-fork node.

| Step | Script | Result |
|---|---|---|
| Builds 1 to 3 | `deploy --env mainnet-fork --impersonate-deployer` | Done |
| RealFi listings | `realfi-list.sh` | Done |
| RWA Safe batch | `safe-batch.sh` | Done |
| Lenders and cushions | `load.sh` | 7.5M USDC, 3M USDrf; six 100k cushions |
| Six pools | `script/Pools.s.sol` | Deployed |
| Split trade | `split-swap.sh` | See below |

| Test | Result |
|---|---|
| 100k USDrf quote, each USDrf pool | 99,700 USDC |
| 100k sUSDrf quote, each sUSDrf pool | 125,984 USDC or USDrf |
| 700k USDrf, one pool | Reverts (400k supply-cap room) |
| 700k USDrf, split RealFi and RWA, one call | 697,900 USDC; 348,950 borrowed per pool |

Deviations from live config: profit receiver set to the Safe; deploy check accepts eUSDrf-2's 15% max discount (Fabio's
check expects 5%); balances written to storage.

Fabio's suites (unit, fork, fuzz, invariant, Sepolia conformance): `RealFiStructures/README.md`; property to test map in
`AUDIT-NOTES.md`.
