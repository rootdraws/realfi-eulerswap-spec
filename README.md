# RealFi on Ethereum: lender-funded pools, routing and risk

AlphaGrowth's RealFi build on Ethereum, for partners reviewing it before they commit capital.

Chain facts were read from an Ethereum archive node at block 26,496,053 (2026-11-25). Code facts cite a file and line.

## Reading order

| Page | Covers |
|---|---|
| [01-overview.md](01-overview.md) | What is built, and why lenders fund the pools |
| [02-contracts-and-audits.md](02-contracts-and-audits.md) | Every contract and who reviewed it |
| [03-uniswap-hooks.md](03-uniswap-hooks.md) | The Uniswap v4 hooks |
| [04-keys.md](04-keys.md) | Who can change or move what |
| [05-alerts.md](05-alerts.md) | Alerts and emergency controls |
| [06-oracles.md](06-oracles.md) | Price feeds |
| [07-liquidations.md](07-liquidations.md) | Liquidations and how outside capital funds them |
| [08-eulerswap-pools.md](08-eulerswap-pools.md) | The lender-funded pools |
| [09-routing-fynd.md](09-routing-fynd.md) | Fynd and its API |
| [10-testing.md](10-testing.md) | The mainnet fork test |
| [11-references.md](11-references.md) | Addresses and documents |

## The repos

| Repo | What it holds | Version read |
|---|---|---|
| [alphagrowth/RealFiStructures](https://github.com/alphagrowth/RealFiStructures) | Fabio's three builds, their tests, the keeper, monitor and liquidator bot, and his audit notes | `fb29ef6` |
| [rootdraws/realfi-eulerswap-spec](https://github.com/rootdraws/realfi-eulerswap-spec) | This spec, and the fork test scripts under [`sources/fork/`](sources/fork/) | this repo |
| [euler-xyz/euler-swap](https://github.com/euler-xyz/euler-swap) | EulerSwap v2, deployed by Euler on Ethereum | `dd936d2` |
| [propeller-heads/tycho-execution](https://github.com/propeller-heads/tycho-execution) and Fynd | The Tycho router and the Fynd route finder | local checkout |

## How to verify

```sh
# a live read: the AlphaGrowth Safe that governs every RealFi vault
cast call 0x4f894Bfc9481110278C356adE1473eBe2127Fd3C 'getThreshold()(uint256)' -r <ethereum rpc>

# Fabio's tests
git clone https://github.com/alphagrowth/RealFiStructures && cd RealFiStructures && nvm use && yarn setup && yarn test:contracts
```

