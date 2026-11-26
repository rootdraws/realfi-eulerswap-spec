# RealFi on Ethereum: lender-funded pools, routing and risk

This spec describes AlphaGrowth's RealFi build on Ethereum. It covers the Euler lending markets, the loop vault, the
Uniswap v4 Rehypothecation pools, the liquidator, the EulerSwap pools and routing through Fynd.

Chain values were read at block 26,496,053 (2026-11-25). Code citations link to the file and line.

| Page | What it covers |
|---|---|
| [1. Overview](01-overview.md) | What was built and why the pools borrow to fill trades |
| [2. Contracts and audits](02-contracts-and-audits.md) | Every contract, its settings and its audits |
| [3. Uniswap v4 hooks](03-uniswap-hooks.md) | The Rehypothecation hooks and the EulerSwap hook |
| [4. Keys and permissions](04-keys.md) | Who can change or move what |
| [5. Alerts and emergency controls](05-alerts.md) | What is monitored and what acts on its own |
| [6. Oracles](06-oracles.md) | The RedStone feeds and how Euler reads them |
| [7. Liquidations](07-liquidations.md) | Euler's settings and how liquidations are funded |
| [8. EulerSwap pools](08-eulerswap-pools.md) | The four pools, their capital and how loans are repaid |
| [9. Routing with Fynd](09-routing-fynd.md) | Fynd's API and what we offer |
| [10. Mainnet fork test](10-testing.md) | The fork test and its results |
| [11. References](11-references.md) | Every address and source document |

| Repo | Contents | Version |
|---|---|---|
| [alphagrowth/RealFiStructures](https://github.com/alphagrowth/RealFiStructures) (private, access on request) | Builds 1 to 3, services and audit notes | `fb29ef6` |
| [euler-xyz/euler-swap](https://github.com/euler-xyz/euler-swap) | EulerSwap v2 | `dd936d2` |
| [propeller-heads/tycho-execution](https://github.com/propeller-heads/tycho-execution) | Tycho router | `c4ed9eb` |
| [propeller-heads/fynd](https://github.com/propeller-heads/fynd) | Fynd route finder | `c7ec565` |
| This repo | This spec and the fork test scripts in [`sources/fork/`](sources/fork/) | |
