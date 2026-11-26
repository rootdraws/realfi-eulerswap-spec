# 9. Routing with Fynd

[Fynd](https://github.com/propeller-heads/fynd), by Propeller Heads, is a routing solution that combines the EulerSwap
pools in both clusters and Fabio's Uniswap v4 Rehypothecation pools into a single transaction. A large order can draw on
the Rehypothecation liquidity and on both USDC vaults at once.

Fynd reads every pool's state each block and finds the split that pays most. It settles through Tycho's router, which
pays the input into Uniswap before each swap, as the EulerSwap hook requires ([Tycho](https://github.com/propeller-heads/tycho-execution/blob/c4ed9eb51dfefe4fc973f33487fa4d51d2407d3a/foundry/src/executors/UniswapV4Executor.sol#L314-L322), [EulerSwap](https://github.com/euler-xyz/euler-swap/blob/dd936d2baaacb9064cf919b1fb45ecaa002d2751/src/UniswapHook.sol#L111)).

## Fynd's API

Propeller Heads hosts the API, and anyone can run their own copy. Both take the same requests.

| | Hosted | Self-hosted |
|---|---|---|
| Address | `https://fynd-api.propellerheads.xyz/v1/ethereum/...` | `http://<host>:3000/v1/...`, after `fynd serve --chain ethereum` |
| Login | A key from the `@fynd_portal_bot` Telegram bot, sent as the `Authorization` header | None |
| Uptime | No promise while in beta | Your own |

| Call | What it does |
|---|---|
| `POST /v1/quote` | Returns the best route and, on request, a transaction ready to send |
| `GET /v1/health` | Reports whether the solver is ready and how fresh its data is |
| `GET /v1/info` | Describes the running solver |

This request quotes a sale of 100k sUSDrf for USDC and asks for the transaction:

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
- The `pool_manager_unlocked` option lets a contract that is already inside a Uniswap v4 call, such as a liquidator, run
  the route within that call.

Sources: [`hosted-api.md`](https://github.com/propeller-heads/fynd/blob/c7ec56515823c684f4acf9bf51e7a9fee13f3e85/docs/get-started/hosted-api.md), [`handlers.rs`](https://github.com/propeller-heads/fynd/blob/c7ec56515823c684f4acf9bf51e7a9fee13f3e85/fynd-rpc/src/api/handlers.rs#L43),
[`lib.rs` L523-L557](https://github.com/propeller-heads/fynd/blob/c7ec56515823c684f4acf9bf51e7a9fee13f3e85/fynd-rpc-types/src/lib.rs#L523-L557).

Our copy of Fynd carries a patch, added 2026-10-21, that lets it read EulerSwap v2 pools. Two questions are open for
our meeting with Propeller Heads on 2026-11-26:

- Does the hosted API read EulerSwap v2 pools?
- Can Fynd simulate Fabio's Rehypothecation hooks?

## Fynd's license

A firm that trades its own capital through Fynd owes Propeller Heads nothing. A firm that charges others for routing
through Fynd owes Propeller Heads 20% of that revenue ([`LICENSE.md`](https://github.com/propeller-heads/fynd/blob/c7ec56515823c684f4acf9bf51e7a9fee13f3e85/LICENSE.md) sections 1.11, 1.13 and 1.15).

## What we offer

Fynd already handles the routing these pools need, so we can offer it either way:

- If Propeller Heads adds EulerSwap pools to the hosted API, partners can call it directly with their own key.
- If it does not, we run our own Fynd instance, which already reads EulerSwap v2 pools, and serve its API to partners.

We set the pool owners, the fee and the pool monitoring ([05](05-alerts.md)) together with each partner.
