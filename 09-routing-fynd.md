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

- **Our copy** at `~/tycho/fynd` already recognizes EulerSwap v2 pools. It is built for Base and is not running now, so it
  needs Tycho's Ethereum data to serve these pools.
- **A partner's copy** can run anywhere. It reads Propeller Heads' hosted Tycho data with a free Tycho API key.
- **The API** is an HTTP server, so we can run one for our own use and a partner can run its own.

### The Fynd API

There are two ways to reach Fynd, and both take the same request and return the same answer.[^api]

| | Hosted by Propeller Heads | Self-hosted |
|---|---|---|
| Address | `https://fynd-api.propellerheads.xyz/v1/ethereum/...` | `http://<host>:3000/v1/...` after `fynd serve --chain ethereum` |
| Login | A Fynd API key from the `@fynd_portal_bot` Telegram bot, sent as the raw `Authorization` header | None |
| Pools it sees | Tycho's default protocol set | Whatever its Tycho data indexes |
| Uptime promise | None while in beta | Your own |

The endpoints:

| Call | What it does |
|---|---|
| `POST /v1/quote` | Finds the best route for one or more orders and, if asked, returns a ready-to-send transaction |
| `GET /v1/health` | Says whether the solver is ready and how fresh its market data is |
| `GET /v1/info` | Describes the running solver |
| `/docs` | Interactive API docs on a self-hosted server |

A quote to sell 100k USDrf for USDC, with the transaction included:

```bash
curl -X POST https://fynd-api.propellerheads.xyz/v1/ethereum/quote \
  -H "Authorization: $FYND_API_KEY" -H "Content-Type: application/json" \
  -d '{
    "orders": [{
      "token_in": "0xD75647217206052F6090678905026AA374431563",
      "token_out": "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
      "amount": "100000000000",
      "side": "sell",
      "sender": "<the wallet that will send it>"
    }],
    "options": { "timeout_ms": 5000, "encoding_options": { "slippage": "0.001", "simulate": true } }
  }'
```

The answer gives the expected output, the route across pools, and the transaction for Tycho's router. Two options matter
here:

- **`simulate`:** Fynd runs the transaction against the latest block before returning it.
- **`pool_manager_unlocked`:** for a caller already inside a Uniswap v4 call, such as a liquidator contract. Fynd's
  Uniswap legs then settle inside the caller's own call.

Whether the hosted API routes through our EulerSwap pools is not confirmed. Our copy of Fynd carries a patch, added
2026-10-21, so that Tycho recognizes EulerSwap v2 hooks.

### License

Fynd's license lets anyone run and change it. A firm trading its own capital owes Propeller Heads nothing on those
gains. A firm that charges others for routing through Fynd owes Propeller Heads 20% of that revenue.[^lic]

## What is left to build

- Point Fynd at Ethereum and confirm it finds all six pools and splits across them.
- Choose who owns the pool accounts, and the fee.
- Add pool checks to the monitor (see [05-alerts.md](05-alerts.md)).

[^fynd]: `~/tycho/fynd/README.md`; EulerSwap v2 recognition in `fynd/Cargo.toml` line 232.
[^api]: `fynd/docs/get-started/hosted-api.md` (address, key, beta terms); `fynd/README.md` (self-hosted quickstart); endpoints in `fynd-rpc/src/api/handlers.rs` line 43 onward and `fynd-rpc/src/api/docs.rs`; request options in `fynd-rpc-types/src/lib.rs` lines 523 to 557.
[^lic]: `fynd/LICENSE.md` sections 1.11 (own-capital trading), 1.13 and 1.15 (a paid service owes 20%).
