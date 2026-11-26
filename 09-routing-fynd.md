# 9. Routing with Fynd

Trades reach the pools through Fynd, a route finder by Propeller Heads. It reads every pool's state each block, splits a
trade across the pools that pay most, and returns a transaction for Tycho's router. That router pays the input into
Uniswap before each swap, which EulerSwap pools need.[^order]

## Fynd's API

| | Hosted by Propeller Heads | Self-hosted |
|---|---|---|
| Address | `https://fynd-api.propellerheads.xyz/v1/ethereum/...` | `http://<host>:3000/v1/...` after `fynd serve --chain ethereum` |
| Login | A key from the `@fynd_portal_bot` Telegram bot, sent as the raw `Authorization` header | None |
| Uptime promise | None while in beta | Your own |

| Call | What it does |
|---|---|
| `POST /v1/quote` | Finds the best route and, if asked, returns a ready-to-send transaction |
| `GET /v1/health` | Says whether the solver is ready and how fresh its data is |
| `GET /v1/info` | Describes the running solver |

A quote to sell 100k sUSDrf for USDC, with the transaction included:[^api]

```bash
curl -X POST https://fynd-api.propellerheads.xyz/v1/ethereum/quote \
  -H "Authorization: $FYND_API_KEY" -H "Content-Type: application/json" \
  -d '{
    "orders": [{
      "token_in": "0x8f4507d315acf966Fe21F9f4feE4F7e1A6d4c400",
      "token_out": "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
      "amount": "100000000000",
      "side": "sell",
      "sender": "<the wallet that will send it>"
    }],
    "options": { "timeout_ms": 5000, "encoding_options": { "slippage": "0.001", "simulate": true } }
  }'
```

- The `simulate` option runs the transaction against the latest block before Fynd returns it.
- The `pool_manager_unlocked` option lets a contract already inside a Uniswap v4 call, such as a liquidator, run the route
  inside its own call.

Our copy of Fynd carries a patch, added 2026-10-21, so that it reads EulerSwap v2 pools. Whether the hosted API reads
them is not confirmed.

## Fynd's license

A firm trading its own capital through Fynd owes Propeller Heads nothing. A firm that charges others for routing through
Fynd owes Propeller Heads 20% of that revenue.[^lic]

## What is left to build

- Run Fynd on Ethereum and confirm it routes across all four pools.
- Choose who owns the pool accounts, and the fee.
- Add the pool checks to the monitor ([05](05-alerts.md)).

[^order]: `euler-swap/src/UniswapHook.sol` line 111; Tycho `tycho-execution/contracts/src/executors/UniswapV4Executor.sol` line 366.
[^api]: `fynd/docs/get-started/hosted-api.md`; `fynd/README.md`; `fynd-rpc/src/api/handlers.rs` line 43 onward; `fynd-rpc-types/src/lib.rs` lines 523 to 557; the patch in `fynd/Cargo.toml` line 232.
[^lic]: `fynd/LICENSE.md` sections 1.11, 1.13 and 1.15.
