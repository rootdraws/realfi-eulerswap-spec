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

## Settings

The fork used a flat curve, sUSDrf priced at RealFi's rate, a 0.30% fee and 100k sUSDrf per pool
([`Pools.s.sol`](sources/fork/script/Pools.s.sol)). The mainnet fee and owner are not chosen yet. The price does not
move on its own, so a manager or fee hook must track RealFi's rate.

## Both clusters in one trade

Fynd can fill one order through the RealFi and RWA pools together, drawing USDC from eUSDC-143 and eUSDC-69 at once. On
the fork, 800k sUSDrf split across both paid 1,008,667 USDC in one transaction ([10](10-testing.md)).

## Capacity

- The sUSDrf vault caps deposits at 2M.
- A pool can borrow only the cash its borrow vault holds.
- A pool fills at 99.7% of value but borrows at most 90%, so its own sUSDrf covers the gap.
- A pool can sell only the sUSDrf it holds.

A separate USDC EVK vault designated as a primary swap venue keeps other borrowers from using up that cash.

## Unwind

Buyers of sUSDrf repay the loans directly. Otherwise:

| Loan | Repaid by | Time |
|---|---|---|
| USDC | Unstaking, then USDrf redemption | 7 days, then RealFi Safe approval with no SLA ([`OPEN-ITEMS.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/OPEN-ITEMS.md) E7) |
| USDrf | Unstaking | 7 days, or immediate if RealFi lists the pool's owner contract for instant unstake |

RealFi must list each pool before it can receive USDrf or sUSDrf.
