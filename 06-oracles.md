# 6. Oracles

## Where the prices come from

RealFi reports the value of USDrf and sUSDrf to RedStone, and RedStone writes those values on chain. These are
issuer-reported values, not prices from a trading pool, so a thin or manipulated pool cannot move them.[^feeds]

| Feed | Address | Value at block 26,496,053 | Last update before that block |
|---|---|---|---|
| RedStone USDrf_FUNDAMENTAL/USD | `0xfd73818CE104EdECb96fb902Bf5ef7Ec840AFD08` | $1.0104 | 3.0 hours |
| RedStone sUSDrf_ETH_FUNDAMENTAL/USD | `0x740C49409bde0a1D74274Faf28abfe09Cf83Ba5A` | $1.2755 | 4.3 hours |

RedStone's stated rule for both feeds is an update when the value moves 0.5%, or every 12 hours if it does not.

## How Euler reads them

Each feed is read through Euler's own price adapter code, the same audited `ChainlinkOracle` adapter Euler uses for any
push feed.

| Adapter | Reads | Refuses a price older than |
|---|---|---|
| `0x0d6482227EEBe29a1a4fED0866ddcdd5DC4BAa45` | the USDrf feed | 13 hours |
| `0x38BB6aA9756419D3F4f13545A50951864a65344a` | the sUSDrf feed | 13 hours |

Both Euler routers, the RealFi cluster's and the RWA cluster's, use these two adapters. USDC is priced at a fixed $1.

Past 13 hours with no update, new borrowing stops, while repayments and withdrawals still work. A fork test
(`ag-euler/contracts/realfi-ethereum/deploy.sh smoke`) ran this case.

## How the loop vault reads them

The loop vault values itself differently from Euler. It prices USDrf from the same RedStone USDrf feed, but prices
sUSDrf through RealFi's own rate (1 sUSDrf = 1.264 USDrf on chain), not through the sUSDrf feed.[^nav]

Euler's sUSDrf price decides the vault's loan health and any liquidation; RealFi's rate decides its share price.

## What RealFi controls

RealFi can book a loss on sUSDrf at once, and nothing in code caps it (Fabio's open item E33). The rate drops in that
block, Euler reprices sUSDrf collateral on the next feed update, and loops can be liquidated before a keeper reacts.
Fabio's monitor pages `SUSDRF_LOSS` on every booked loss.

[^feeds]: Read at block 26,496,053 (timestamp 1,795,656,167): `latestRoundData()` and `description()` of both feeds; update timestamps 1,795,645,367 and 1,795,640,855. Update rule: `ag-euler/contracts/realfi-ethereum/deploy.sh` lines 43 and 44. Adapters: `feed()` and `maxStaleness()` (46,800 s) read at the same block; `getConfiguredOracle` on both routers returns the two adapters, and both quote 1 USDC as $1, at the same block.
[^nav]: `RealFiStructures/docs/AUDIT-NOTES.md` terms table ("EulerRouter") and section 2.2; sUSDrf `convertToAssets(1e6)` = 1,264,048.
