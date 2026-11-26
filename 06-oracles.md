# 6. Oracles

| Feed | Address | Value | Age at read |
|---|---|---|---|
| RedStone USDrf_FUNDAMENTAL/USD | [`0xfd73818CE104EdECb96fb902Bf5ef7Ec840AFD08`](https://etherscan.io/address/0xfd73818CE104EdECb96fb902Bf5ef7Ec840AFD08) | $1.0104 | 3.0 h |
| RedStone sUSDrf_ETH_FUNDAMENTAL/USD | [`0x740C49409bde0a1D74274Faf28abfe09Cf83Ba5A`](https://etherscan.io/address/0x740C49409bde0a1D74274Faf28abfe09Cf83Ba5A) | $1.2755 | 4.3 h |

Deviation 0.5%, heartbeat 12 h (RedStone's stated parameters).

| Euler adapter (`ChainlinkOracle`) | Feed | `maxStaleness` |
|---|---|---|
| [`0x0d6482227EEBe29a1a4fED0866ddcdd5DC4BAa45`](https://etherscan.io/address/0x0d6482227EEBe29a1a4fED0866ddcdd5DC4BAa45) | USDrf | 46,800 s |
| [`0x38BB6aA9756419D3F4f13545A50951864a65344a`](https://etherscan.io/address/0x38BB6aA9756419D3F4f13545A50951864a65344a) | sUSDrf | 46,800 s |

- Both routers use both adapters; USDC is fixed at $1.
- Stale feed: borrows revert; repay and withdraw work (`ag-euler/contracts/realfi-ethereum/deploy.sh smoke`).
- Build 1 NAV prices sUSDrf by `convertToAssets`, not the feed; Euler's LTV uses the feed ([`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md) section 2.2,
  item 20 of 2.4).
- RealFi loss booking is uncapped in code (E33); monitor pages `SUSDRF_LOSS`.

Reads at block 26,496,053: `latestRoundData`, `feed`, `maxStaleness`, `getConfiguredOracle`.
