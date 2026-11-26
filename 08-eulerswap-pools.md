# 8. EulerSwap pools

Each pool runs EulerSwap v2 ([euler-xyz/euler-swap](https://github.com/euler-xyz/euler-swap/tree/dd936d2baaacb9064cf919b1fb45ecaa002d2751)
at `dd936d2`) from Euler's factory
[`0xD05213331221fAB8a3C387F2affBb605Bb04DF5F`](https://etherscan.io/address/0xD05213331221fAB8a3C387F2affBb605Bb04DF5F)
on its own EVC sub-account.

| Pool | Pair | Borrows from |
|---|---|---|
| RealFi A | sUSDrf <> USDC | eUSDC-143 |
| RealFi B | sUSDrf <> USDrf | eUSDrf-2 |
| RWA A | sUSDrf <> USDC | eUSDC-69 |
| RWA B | sUSDrf <> USDrf | eUSDrf-1 |

A sale of sUSDrf to a pool is paid with a loan. A purchase of sUSDrf from a pool repays it.

## Loop vaults balance the pools

- Loops winding up buy sUSDrf from the pools, which repays the pools' loans.
- Loops winding down or liquidated sell sUSDrf to the pools, which borrow to pay them.
- When the pools hold no sUSDrf, loops buy USDrf and stake it instead.

The pools' sUSDrf earns RealFi's yield above the borrow rate while it waits for buyers. Wave, as the USDC lender, earns
the borrow rate, and earns the fee and the carry too if it runs a pool.

## Splitting large orders across both clusters

Fynd splits a large sale between the RealFi and RWA pools in one transaction, drawing on both USDC vaults. On the fork,
800k sUSDrf sold for 1,008,667 USDC, a 0.30% cost that is the pool fee alone ([10](10-testing.md)).

## Limits and required capital

- The sUSDrf vault takes at most 2M.
- A pool borrows only the cash left in its borrow vault, unless a USDC EVK vault is designated as its primary swap venue.
- A pool sells only the sUSDrf it holds.

An Eulerswap pool pays 99.7% of value but borrows at most 90%.

This means that the Owner of the Pool must hold sUSDrf as collateral to maintain the health of the Eulerswap Pool. 

For a pool that buys 1M
sUSDrf:[^health]

| Pool | 90% LTV | 80% LTV |
|---|---|---|
| sUSDrf <> USDC | 98k sUSDrf ($126k) | 236k sUSDrf ($301k) |
| sUSDrf <> USDrf | 110k sUSDrf ($140k) | 248k sUSDrf ($316k) |

At 90%, the borrow limit, a 2.2% fall in Euler's sUSDrf price reaches liquidation.

## Repaying the loans

Loops buying sUSDrf repay the loans. Without buyers, the pool's owner unstakes the sUSDrf: 7 days for a USDrf loan, or at
once if RealFi lists the owner for instant unstake. A USDC loan then also waits for RealFi's Safe to approve the redemption, with no SLA
([`OPEN-ITEMS.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/OPEN-ITEMS.md) E7).

RealFi must list each pool before it can receive USDrf or sUSDrf, and must allowlist the owner before it can redeem USDrf
for USDC.

## How a pool tracks RealFi's rate

A swap hook tracks RealFi's live rate with no keeper. EulerSwap calls its `getFee` on every swap
([`QuoteLib.sol` L20-L29](https://github.com/euler-xyz/euler-swap/blob/dd936d2baaacb9064cf919b1fb45ecaa002d2751/src/libraries/QuoteLib.sol#L20-L29)), and its `afterSwap` moves the pool's price when the rate drifts. The shMON exit desk on Monad runs this today. The fork used a fixed price, a 0.30% fee
and 100k sUSDrf per pool ([`Pools.s.sol`](sources/fork/script/Pools.s.sol)); the mainnet fee and owner are open.

[^health]: Own sUSDrf = sUSDrf bought × (0.997 × pool price × debt price / (loan level × Euler's sUSDrf price) − 1), with pool price 1.264628 USDrf per sUSDrf and Euler prices of $1.2755 (sUSDrf) and $1.0104 (USDrf). Checked on the fork: the RealFi USDC pool held 342,325 sUSDrf, worth $392,966 to Euler at 90%, against 304,334 USDC of debt.
