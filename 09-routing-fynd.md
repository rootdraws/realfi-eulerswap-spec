# 9. Routing and Fynd

## The problem a router must solve

An EulerSwap pool pulls the seller's tokens out of Uniswap during the swap (`euler-swap/src/UniswapHook.sol` line 111).
Uniswap holds no USDrf of its own, so the seller's USDrf must already be paid into Uniswap when the swap runs.

A router that swaps first and pays after fails on these pools. A router that pays first works.

## Which routers work

| Router | Order | Result |
|---|---|---|
| Uniswap's Universal Router, built by Uniswap's SDK for a plain v4 trade | Swaps, then pays | Fails: the fork run reverted with Uniswap short of USDrf |
| Uniswap's Universal Router, with the payment step first | Pays, then swaps | Works: proven on the fork |
| Uniswap's SDK, for a route that mixes v4 with v2 or v3 pools | Pays, then swaps | Works, by the same order |
| EulerSwap's own periphery | Sends tokens to the pool, then swaps | Works, one pool at a time |
| Tycho's router, which Fynd uses | Pays, then swaps | Works, by its code |

Sources: Uniswap SDK `universal-router-sdk/src/entities/actions/uniswap.ts` lines 516 and 517 (swap, then pay) and line
640 (pay first); Tycho `tycho-execution/contracts/src/executors/UniswapV4Executor.sol` line 366 (pay first).

Fabio's own hooks avoid the problem a different way: they take Uniswap IOUs when Uniswap holds no USDrf, and turn them
into tokens later.

## Splitting one trade across pools

Uniswap v4 keeps one running balance for the whole router call and settles it at the end. So one call can sell through
the RealFi pool and the RWA pool together, and the trader pays and is paid once.

On the fork, selling 700k USDrf into one pool reverted, because that pool could take only 400k. Splitting the same
700k into 350k for each pool, in one router call, paid 697,900 USDC. Each pool borrowed 348,950 USDC from its own
cluster's USDC vault.

## Fynd

Fynd is a route finder built on Tycho by Propeller Heads. It reads every pool's state each block, finds the split across
pools that pays most after gas, and builds the transaction for Tycho's router.[^fynd]

- **Our copy** at `~/tycho/fynd` already recognizes EulerSwap v2 pools. It runs on Base today, so it needs Tycho's
  Ethereum data to serve these pools.
- **A partner's copy** can run anywhere. It reads Propeller Heads' hosted Tycho data with a free Tycho API key.
- **The API** is an HTTP server, so we can run one for our own use and a partner can run its own.

### License

Fynd's license lets anyone run and change it. A firm trading its own capital owes Propeller Heads nothing on those
gains. A firm that charges others for routing through Fynd owes Propeller Heads 20% of that revenue.[^lic]

## What is left to build

- Point Fynd at Ethereum and confirm it finds all six pools and splits across them.
- Choose who owns the pool accounts, and the fee.
- Add pool checks to the monitor (see [05-alerts.md](05-alerts.md)).

[^fynd]: `~/tycho/fynd/README.md`; EulerSwap v2 recognition in `fynd/Cargo.toml` line 232.
[^lic]: `fynd/LICENSE.md` sections 1.11 (own-capital trading), 1.13 and 1.15 (a paid service owes 20%).
