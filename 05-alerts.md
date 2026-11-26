# 5. Alerts and emergency controls

Fabio's services watch every RealFi Structures contract and each outside dependency on every tick, about every 12
seconds. His full write-up is `RealFiStructures/docs/RISK-ALERTS.md`; this page summarizes it.[^alerts]

## What runs

| Service | Watches | Can act |
|---|---|---|
| Position monitor | The loop vault, both pools, RealFi, Euler, the price feeds and the bot wallets | Pauses the vault through the guardian key; tops up bot wallets with gas |
| Loop keeper | The vault's loan, borrow cost, withdrawals and redemptions | De-levers the vault; pays withdrawals |
| Scanner | The chain's event streams | Reads only |
| Liquidator bot | Borrowers in our Euler markets | Liquidates unhealthy loans |

## What raises an alert

There are about 150 alert codes, each a stable name a partner can filter on.

| Area | Raised when | Example codes |
|---|---|---|
| Vault leverage | The loan passes the 70% target (warn), 78% (critical) or 85% (critical, and the guardian pauses) | `LTV_ABOVE_TARGET`, `LTV_PANIC`, `OWN_VAULT_LIQUIDATABLE` |
| Prices | A RedStone feed goes stale, a price read reverts, the vault's share price jumps over 0.5% in a tick, or sUSDrf's rate falls | `FEED_STALE`, `NAV_PRICE_STEP`, `SUSDRF_LOSS` |
| RealFi | RealFi pauses USDrf, sUSDrf or claims, or removes one of our contracts from its lists | `REALFI_PAUSED`, `ACCESS_UNLISTED` |
| Withdrawals | A redemption waits over 24 hours (warn) or 7 days (critical), or a de-lever cannot run | `REDEMPTION_PENDING_LONG`, `DELEVER_STUCK` |
| Pools | A pool trades below $1 or outside its range, runs low, or freezes exits | `POOL_PRICE_BELOW_PAR`, `POOL_EXITS_FROZEN` |
| Liquidations | A loan in our markets becomes liquidatable, or a liquidation fails | `LIQUIDATION_REVERTED`, `LIQUIDATOR_RESERVE_LOW` |
| Operations | A service stops, the chain head stalls, a transaction sticks, or a wallet runs low on gas | `SERVICE_DOWN`, `BLOCK_STALE`, `GAS_WALLET_LOW` |

Thresholds sit in configuration (`deploy/configs/mainnet/runtime.json`), so a limit tightens without a code release.

## How alerts reach people

| Level | Meaning | Repeats while active |
|---|---|---|
| info | No action needed; logged only | Never |
| warn | A limit is near | Every 6 hours |
| critical | A limit is crossed | Every 15 minutes |

- **Telegram:** the team's alert chat.
- **Webhook:** any HTTPS endpoint gets each alert as JSON. A partner can point Slack, PagerDuty or its own system here.
- **Dead-man ping:** the monitor pings an outside health check on every healthy tick. If the pings stop, that service
  pages the team, which also covers a dead Telegram.
- **Dashboard:** every alert is stored with its history and shown on the operator dashboard.

A partner can receive a chosen set of codes, such as every critical alert, at an endpoint it owns.

## What acts on its own

1. **The keeper de-levers.** Past 78%, it unwinds the vault back to 70%, at most a quarter of the debt per transaction,
   through RealFi's instant unstake.
2. **The guardian pauses.** At 85%, or whenever the monitor cannot finish a tick, it pauses the vault. If it cannot see,
   it pauses.
3. **The admin decides the rest.** Only the admin can unpause a pool, halt a contract or upgrade.

A pause stops new risk but leaves open every exit that lowers it: de-levers, repayments and withdrawals already asked
for.

## What the alerts do not cover yet

- **The EulerSwap pools.** No service watches them yet. The checks to add are each pool's loan health, the room left in
  the vault it borrows from, and how long RealFi takes to repay its loans.
- **Third-party monitoring.** None of our three repos (RealFiStructures, ag-euler, alphastructures) sets up Hypernative or
  another outside monitor.

[^alerts]: `RealFiStructures/docs/RISK-ALERTS.md` (Nov 25, 2026); service tick lengths in `deploy/configs/mainnet/runtime.json` (`tickMs` 12000).
