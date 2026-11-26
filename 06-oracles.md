# 6. Oracles

RealFi reports USDrf and sUSDrf values to RedStone, which pushes them on chain. RedStone states a 0.5% deviation
trigger and a 12-hour heartbeat for both feeds.

| Feed | Address | Value at block 26,496,053 | Age |
|---|---|---|---|
| RedStone USDrf_FUNDAMENTAL/USD | [`0xfd73818CE104EdECb96fb902Bf5ef7Ec840AFD08`](https://etherscan.io/address/0xfd73818CE104EdECb96fb902Bf5ef7Ec840AFD08) | $1.0104 | 3.0 h |
| RedStone sUSDrf_ETH_FUNDAMENTAL/USD | [`0x740C49409bde0a1D74274Faf28abfe09Cf83Ba5A`](https://etherscan.io/address/0x740C49409bde0a1D74274Faf28abfe09Cf83Ba5A) | $1.2755 | 4.3 h |

Euler reads each feed through its audited `ChainlinkOracle` adapter, which rejects a price older than 13 hours
([L66-L69](https://github.com/euler-xyz/euler-price-oracle/blob/18a3e34d516992b38797a1c61ebbf7dd8e957dcd/src/adapter/chainlink/ChainlinkOracle.sol#L66-L69)).

| Adapter | Feed | `maxStaleness` |
|---|---|---|
| [`0x0d6482227EEBe29a1a4fED0866ddcdd5DC4BAa45`](https://etherscan.io/address/0x0d6482227EEBe29a1a4fED0866ddcdd5DC4BAa45) | USDrf | 46,800 s |
| [`0x38BB6aA9756419D3F4f13545A50951864a65344a`](https://etherscan.io/address/0x38BB6aA9756419D3F4f13545A50951864a65344a) | sUSDrf | 46,800 s |

- Both routers use both adapters, and USDC is fixed at $1.
- A stale feed blocks new borrowing. Repayments and withdrawals still work, as the fork test in
  `ag-euler/contracts/realfi-ethereum/deploy.sh smoke` shows.
- The loop vault values sUSDrf by RealFi's rate, while Euler values it by the feed
  ([`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md) section 2.2).
- RealFi can book a loss with no cap in code (open item E33). The monitor alerts on every loss (`SUSDRF_LOSS`).
