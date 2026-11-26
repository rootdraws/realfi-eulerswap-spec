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

- When a trader sells sUSDrf, the pool borrows USDC or USDrf against it.
- When a trader buys sUSDrf, the incoming USDC or USDrf repays the loan. The pool never borrows sUSDrf.

## Pool settings on the fork

The fork used a flat curve, sUSDrf priced at RealFi's rate, a 0.30% fee and 100k sUSDrf per pool
([`Pools.s.sol`](sources/fork/script/Pools.s.sol)). The mainnet fee and owner are not chosen yet. The price does not
move on its own, so a manager or fee hook must track RealFi's rate.

## Splitting large orders across the RealFi and RWA clusters

A large sUSDrf sale can draw on the USDC in both clusters. Fynd splits the order between the RealFi pool, which borrows
from eUSDC-143, and the RWA pool, which borrows from eUSDC-69. Uniswap v4 settles both legs in a single transaction.

On the fork, one transaction sold 800k sUSDrf this way ([10](10-testing.md)):

| | USDC |
|---|---|
| Fair value at the pool's price of 1.264628 USDrf per sUSDrf, with USDrf at $1 | 1,011,702 |
| Received | 1,008,667 |
| Cost of execution | 3,035 (0.30%, the pool fee; no slippage on the flat curve) |

## How the pools and the USDC lender earn

- The sUSDrf a pool holds earns RealFi's yield, while the pool pays the USDC lender's borrow rate. The pool keeps the
  difference, a carry trade.
- Wave, as the USDC lender, earns the borrow rate on what the pools draw. If Wave also runs a pool account, it adds the
  pool's trading fees and the carry.

## What limits a pool's size

- The sUSDrf vault caps deposits at 2M.
- A pool can borrow only the cash its borrow vault holds.
- A pool fills at 99.7% of value but borrows at most 90%, so its own sUSDrf covers the gap.
- A pool can sell only the sUSDrf it holds.

A separate USDC EVK vault designated as a primary swap venue keeps other borrowers from using up that cash.

## Repaying the loans

Buyers of sUSDrf repay the loans directly. Otherwise:

| Loan | Repaid by | Time |
|---|---|---|
| USDC | Unstaking, then USDrf redemption | 7 days, then RealFi Safe approval with no SLA ([`OPEN-ITEMS.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/OPEN-ITEMS.md) E7) |
| USDrf | Unstaking | 7 days, or immediate if RealFi lists the pool's owner contract for instant unstake |

RealFi must list each pool before it can receive USDrf or sUSDrf.
