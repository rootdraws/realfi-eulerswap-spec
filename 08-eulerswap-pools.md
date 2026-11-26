# 8. EulerSwap pools

EulerSwap v2 as deployed by Euler (factory `0xD05213331221fAB8a3C387F2affBb605Bb04DF5F`), one EVC sub-account per pool.

| Pool | Pair | Supply vaults | Borrow vault |
|---|---|---|---|
| RealFi A | sUSDrf <> USDC | esUSDrf-2, eUSDC-143 | eUSDC-143 |
| RealFi B | sUSDrf <> USDrf | esUSDrf-2, eUSDrf-2 | eUSDrf-2 |
| RWA A | sUSDrf <> USDC | esUSDrf-1, eUSDC-69 | eUSDC-69 |
| RWA B | sUSDrf <> USDrf | esUSDrf-1, eUSDrf-1 | eUSDrf-1 |

- **sUSDrf in:** the pool borrows the output token against the sUSDrf it receives.
- **sUSDrf out:** the incoming USDC or USDrf repays the loan, and the pool pays from its own sUSDrf; sUSDrf is never
  borrowed.

Fork parameters (`sources/fork/script/Pools.s.sol`): `concentration` 1e18 (flat), sUSDrf priced at RealFi's rate at
deploy, fee 0.30%, 100k sUSDrf per account as initial stock and cushion. Fee and owner for mainnet are open. The price is
static; a fee hook or manager must track the rate.

## Capacity

Bounded by the sUSDrf vault's 2M cap, the borrow vault's cash, and the cushion (fill at 99.7% of value against a 90%
borrow LTV). Sales of sUSDrf are bounded by the account's sUSDrf.

## Unwind

Buyers of sUSDrf repay the loans directly. Otherwise:

| Loan | Repaid by | Time |
|---|---|---|
| USDC | Unstake, then USDrf redemption | 7 days, then RealFi Safe approval; no SLA (`OPEN-ITEMS.md` E7) |
| USDrf | Unstake | 7 days; immediate if RealFi lists the account's owner contract for instant unstake |

RealFi must list each pool on its access list before it can receive USDrf or sUSDrf.
