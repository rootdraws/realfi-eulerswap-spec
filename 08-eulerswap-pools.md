# 8. EulerSwap pools

EulerSwap v2 as deployed by Euler (factory `0xD05213331221fAB8a3C387F2affBb605Bb04DF5F`), one EVC sub-account per pool.

| Pool | In | Out | Supply vault | Borrow vault |
|---|---|---|---|---|
| RealFi A | USDrf | USDC | eUSDrf-2 | eUSDC-143 |
| RealFi B | sUSDrf | USDrf | esUSDrf-2 | eUSDrf-2 |
| RWA A | USDrf | USDC | eUSDrf-1 | eUSDC-69 |
| RWA B | sUSDrf | USDrf | esUSDrf-1 | eUSDrf-1 |

Fork parameters (`sources/fork/script/Pools.s.sol`): one-sided, `concentration` 1e18 (flat), price $1 for USDrf and
RealFi's rate at deploy for sUSDrf, fee 0.30%, 100k cushion of the input token per account. Fee and owner for mainnet are
open. The sUSDrf price is static; a fee hook or manager must track the rate.

## Capacity

Bounded by the supply vault's cap (2M USDrf or sUSDrf), the borrow vault's cash, and the cushion (fill at 99.7% of value
against a 93% or 90% borrow LTV).

## Unwind

| Pool | Repaid by | Time |
|---|---|---|
| A | USDrf redemption | Each mainnet redemption needs RealFi's Safe approval; no SLA (`OPEN-ITEMS.md` E7) |
| B | Unstake | 7 days; immediate if RealFi lists the pool's owner contract on the StakeDesk for instant unstake |

RealFi must list each pool on its access list before it can receive USDrf or sUSDrf.
