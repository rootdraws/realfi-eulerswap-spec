# RealFi on Ethereum: lender-funded pools, routing and risk

This spec covers AlphaGrowth's RealFi build on Ethereum. Chain values were read at block 26,496,053 (2026-11-25), and code
citations link to the file and line.

| Page | Covers |
|---|---|
| [01](01-overview.md) | Overview |
| [02](02-contracts-and-audits.md) | Contracts and audits |
| [03](03-uniswap-hooks.md) | Uniswap v4 hooks |
| [04](04-keys.md) | Keys and permissions |
| [05](05-alerts.md) | Alerts and emergency controls |
| [06](06-oracles.md) | Oracles |
| [07](07-liquidations.md) | Liquidations |
| [08](08-eulerswap-pools.md) | EulerSwap pools |
| [09](09-routing-fynd.md) | Fynd |
| [10](10-testing.md) | Mainnet fork test |
| [11](11-references.md) | Addresses and documents |

| Repo | Contents | Version |
|---|---|---|
| [alphagrowth/RealFiStructures](https://github.com/alphagrowth/RealFiStructures) (private; access on request) | Builds 1 to 3, services, audit notes | `fb29ef6` |
| [euler-xyz/euler-swap](https://github.com/euler-xyz/euler-swap) | EulerSwap v2 | `dd936d2` |
| [propeller-heads/tycho-execution](https://github.com/propeller-heads/tycho-execution) | Tycho router | `main` |
| This repo | Spec; fork scripts in [`sources/fork/`](sources/fork/) | |
