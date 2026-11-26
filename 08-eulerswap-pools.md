# 8. EulerSwap pools

The pools run EulerSwap v2 from Euler's factory
[`0xD05213331221fAB8a3C387F2affBb605Bb04DF5F`](https://etherscan.io/address/0xD05213331221fAB8a3C387F2affBb605Bb04DF5F).
Each pool trades from its own EVC sub-account.

| Pool | Pair | Supply vaults | Borrow vault |
|---|---|---|---|
| RealFi A | sUSDrf <> USDC | esUSDrf-2, eUSDC-143 | eUSDC-143 |
| RealFi B | sUSDrf <> USDrf | esUSDrf-2, eUSDrf-2 | eUSDrf-2 |
| RWA A | sUSDrf <> USDC | esUSDrf-1, eUSDC-69 | eUSDC-69 |
| RWA B | sUSDrf <> USDrf | esUSDrf-1, eUSDrf-1 | eUSDrf-1 |

- When a trader sells sUSDrf, the pool borrows USDC or USDrf to pay, against the sUSDrf it receives.
- When a trader buys sUSDrf, the incoming USDC or USDrf repays that loan. The pool never borrows sUSDrf.

## Loop vaults balance the pools

Loop vaults borrow USDC or USDrf to hold more sUSDrf, so they trade with the pools in both directions.

- **Winding up:** a loop buys sUSDrf from the pools. That repays the pools' loans and frees their borrowing capacity.
- **Winding down or liquidated:** a loop sells sUSDrf into the pools, which borrow to pay it.
- **When the pools run out of sUSDrf:** a loop buys USDrf and stakes it instead.

One loop's exit fills the capacity another loop's entry created. While the pools wait for buyers, their sUSDrf earns
RealFi's yield above the borrow rate, so the inventory carries positively.

## How the pools and the USDC lender earn

- A pool earns RealFi's yield on its sUSDrf, pays the borrow rate on its loan, and keeps the 0.30% fee.
- Wave, as the USDC lender, earns the borrow rate on what the pools draw. If Wave also runs a pool account, it earns the
  fee and the carry as well.

## Splitting large orders across the RealFi and RWA clusters

Fynd splits a large sUSDrf sale between the RealFi pool, which borrows from eUSDC-143, and the RWA pool, which borrows
from eUSDC-69. Uniswap v4 settles both legs in one transaction. On the fork, one transaction sold 800k sUSDrf this way
([10](10-testing.md)):

| | USDC |
|---|---|
| Fair value at the pool's price of 1.264628 USDrf per sUSDrf, with USDrf at $1 | 1,011,702 |
| Received | 1,008,667 |
| Cost of execution | 3,035 (0.30%, the pool fee; no slippage on the flat curve) |

## What limits a pool's size

- The sUSDrf vault caps deposits at 2M.
- A pool can borrow only the cash left in its borrow vault. A separate USDC EVK vault designated as a primary swap venue
  keeps other borrowers from using that cash.
- A pool can sell only the sUSDrf it holds.
- A pool pays 99.7% of value but may borrow only 90% of it, so it must hold its own sUSDrf to cover the gap.

To stay within the 90% borrow limit, a pool must hold its own sUSDrf worth about 9.8% of the sUSDrf it buys (USDC pool)
or 11% (USDrf pool). At that limit a 2.2% fall in Euler's sUSDrf price reaches the 92% liquidation line, so holding 24%
to 25% keeps the loan at 80%.[^health]

Own sUSDrf = sUSDrf bought × (0.997 × pool price × debt token price / (LTV × Euler's sUSDrf price) − 1), with a pool
price of 1.264628 USDrf per sUSDrf and Euler's prices of $1.2755 for sUSDrf and $1.0104 for USDrf.

## Repaying the loans

Loops buying sUSDrf repay the loans as they wind up. Without buyers, the pool repays through RealFi:

| Loan | Repaid by | Time |
|---|---|---|
| USDC | Unstaking, then USDrf redemption | 7 days, then RealFi Safe approval with no SLA ([`OPEN-ITEMS.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/OPEN-ITEMS.md) E7) |
| USDrf | Unstaking | 7 days, or immediate if RealFi lists the pool's owner contract for instant unstake |

RealFi must list each pool before it can receive USDrf or sUSDrf.

## Pool settings on the fork

The fork used a flat curve, sUSDrf priced at RealFi's rate, a 0.30% fee and 100k sUSDrf per pool
([`Pools.s.sol`](sources/fork/script/Pools.s.sol)). The mainnet fee and owner are not chosen yet. The price does not
move on its own, so a manager or fee hook must track RealFi's rate.

[^health]: Checked on the fork: the RealFi USDC pool's account held 342,325 sUSDrf, which Euler values at $392,966 after the 90% LTV (`accountLiquidity`), against 304,334 USDC of debt. Prices from the RealFi router's `getQuote`.
