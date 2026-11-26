# RealFi on Ethereum: lender-funded pools, routing and risk

A technical overview for partners reviewing AlphaGrowth's RealFi work on Ethereum before they commit capital. It covers
the Euler lending markets for USDrf and sUSDrf, Fabio's three builds (the loop vault, the Uniswap v4 pool hooks and the
liquidator), the EulerSwap pools that borrow to pay sellers, and Fynd, the route finder that sends trades through all of
them.

Chain facts were read from an Ethereum archive node at block 26,496,053 (2026-11-25). Code facts cite a file and line.

## Reading order

| Page | What it covers | Partner question it answers |
|---|---|---|
| [01-overview.md](01-overview.md) | What is built, and why lenders fund the pools instead of LPs | |
| [02-contracts-and-audits.md](02-contracts-and-audits.md) | Every contract, where it lives, and who has reviewed it | Contracts and audits |
| [03-uniswap-hooks.md](03-uniswap-hooks.md) | The three Uniswap v4 hooks and their review status | The Uniswap hook |
| [04-keys.md](04-keys.md) | Who can change or move what | Keys and permissions |
| [05-alerts.md](05-alerts.md) | What is watched, how alerts reach people, and what acts on its own | Alerts |
| [06-oracles.md](06-oracles.md) | How USDrf and sUSDrf prices reach Euler and the vault | Oracles |
| [07-liquidations.md](07-liquidations.md) | How liquidations run, and how outside capital can fund them | Liquidation money |
| [08-eulerswap-pools.md](08-eulerswap-pools.md) | The six lender-funded pools and what limits their depth | |
| [09-routing-fynd.md](09-routing-fynd.md) | Which routers can trade the pools, and Fynd | |
| [10-testing.md](10-testing.md) | The mainnet fork test, its results and how to rerun it | |
| [11-references.md](11-references.md) | Every address and repo | |

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

The fork test that deploys everything and trades through it is in [10-testing.md](10-testing.md).
