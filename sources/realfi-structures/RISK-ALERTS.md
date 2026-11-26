# RealFi Structures: Risk Alerts and Emergency Controls

Nov 25, 2026

## Overview

Off-chain services watch every RealFi Structures contract and each external dependency on every tick. They raise an alert when a risk limit is near or crossed, and two of them can act on chain without waiting for a person.

| Service | Code | Watches | Can act |
| --- | --- | --- | --- |
| Position monitor | `services/positionMonitor` | The looping vault, both pools, RealFi, Euler, price feeds, role wallets | Guardian pause; gas top-ups of the bot wallets |
| Loop keeper | `services/keeper` | Vault LTV, borrow cost, withdrawals, redemptions | De-levers the vault; pays withdrawals |
| Scanner | `services/scanner` | On-chain event streams the other services read | Read only |
| Liquidator bot (Build 3) | `services/liquidator` | Borrowers in our Euler markets | Liquidates unhealthy positions |

Every service shares one alert pipeline (`packages/shared/src`), so a new check or a new delivery channel is added once and serves all of them.

## What we alert on today

About 150 alert codes cover seven risk areas. Each code is a stable name (for example `LTV_PANIC`) that partners can filter, route or subscribe to.

| Risk area | What triggers an alert | Example codes | Where in code |
| --- | --- | --- | --- |
| Vault leverage (Build 1) | LTV above the 70% target (warn), the 78% controlled band (critical), the 85% panic band (critical, guardian pauses); Euler borrow limit near; the vault becoming liquidatable | `LTV_ABOVE_TARGET`, `LTV_ABOVE_CONTROLLED`, `LTV_PANIC`, `EULER_BORROW_LIMIT_NEAR`, `OWN_VAULT_LIQUIDATABLE` | `services/positionMonitor/src/build1/checks.ts` |
| Prices and NAV | A RedStone feed (USDrf or sUSDrf) going stale; a price read reverting; the vault's share price stepping more than 0.5% in one tick; sUSDrf's rate falling | `FEED_STALE`, `FEED_QUOTE_REVERTS`, `NAV_PRICE_STEP`, `RATE_DROP`, `SUSDRF_LOSS` | same |
| RealFi dependencies | RealFi pausing USDrf, sUSDrf or claims; one of our contracts losing its access-list or allowlist entry; StakeDesk role changes | `REALFI_PAUSED`, `REALFI_CLAIM_PAUSED`, `ACCESS_UNLISTED`, `ALLOWLIST_MISSING` | same |
| Withdrawals and de-levers | A redemption pending over 24 h (warn) or 7 days (critical); a de-lever that cannot run; RealFi's redemption reserve short; borrow cost above yield | `REDEMPTION_PENDING_LONG`, `DELEVER_STUCK`, `REDEEM_RESERVE_SHORT`, `NEGATIVE_CARRY` | `services/keeper/src/loop` |
| Pools (Build 2) | Pool price below par or outside its range; low liquidity; LP value drop; exits frozen; a pool paused or halted | `POOL_PRICE_BELOW_PAR`, `POOL_LIQUIDITY_LOW`, `POOL_LP_VALUE_DROP`, `POOL_EXITS_FROZEN`, `POOL2_PRICE_BELOW_RANGE` | `services/positionMonitor/src/build2` |
| Liquidations (Build 3) | A position in our markets liquidatable; a liquidation reverting or unprofitable; the liquidator's reserve low | `LIQUIDATION_REVERTED`, `LIQUIDATOR_RESERVE_LOW`, `MORPHO_LIQUIDATABLE` | `services/liquidator/src` |
| Operations | A service down or failing ticks; the chain head stale; a stuck transaction; a bot wallet low on gas; a role missing | `SERVICE_DOWN`, `BLOCK_STALE`, `TX_BUMPS_EXHAUSTED`, `GAS_WALLET_LOW`, `GUARDIAN_ROLE_MISSING` | `packages/shared/src` |

Thresholds live in configuration, not code (`deploy/configs/mainnet/runtime.json`), so a limit can be tightened without a release.

## Severity and delivery

Every alert has one of three levels, and the level decides who hears it and how often.

| Level | Meaning | Delivered | Repeats while active |
| --- | --- | --- | --- |
| info | Context, no action needed | Log and database only | Never |
| warn | A limit is near; watch it | Every channel below | Every 6 h |
| critical | A limit is crossed; act now | Every channel below | Every 15 min |

A level that rises is sent at once, and a cleared alert sends a matching `<CODE>_RESOLVED` message. Price-band alerts use hysteresis (two ticks to raise, three to clear), so a price sitting on a boundary does not flap. The policy is in `packages/shared/src/alerts.ts` and the `alerts` block of the runtime config.

Channels today (`packages/shared/src/telemetry.ts`):

- **Telegram:** the team's alert chat; each message names the environment and the alert code.
- **Webhook:** any HTTPS endpoint (`ALERTS_WEBHOOK_URL`) receives each alert as JSON. This is the hook for Slack, PagerDuty, email gateways or a partner's own system.
- **Dead-man ping:** the monitor pings an external health check (healthchecks.io or similar) every healthy tick. If the pings stop, because the host, the database or the monitor itself is down, that service pages us. It also covers a failing Telegram.
- **Database and dashboard:** every alert is stored with its history in MongoDB and shown on the operator dashboard (`www-ops`, served by `api/src/routes/ops.ts`).

Delivery is retried on network errors, respects rate limits, and never blocks the service that raised the alert.

## Emergency controls

Three layers respond to a risk, from automatic to manual. A pause stops new risk from being taken but always leaves the exits that reduce it.

**1. Keeper de-lever (automatic).** When the vault's LTV passes the 78% controlled band, the keeper unwinds it back to the 70% target, at most 25% of the debt per transaction, using RealFi's instant unstake (`services/keeper/src/loop`).

**2. Guardian pause (automatic).** The guardian is a dedicated key held only by the position monitor (`services/positionMonitor/src/build1/guardian.ts`). It pauses the vault on its own when:

- the LTV reaches the 85% panic band, or
- the monitor cannot finish a tick (an RPC or database failure): if it cannot see, it pauses.

The pause transaction bids above the market fee so it lands in the next blocks. The guardian lifts only its own pause, and only after the LTV has stayed at or below target for 30 minutes. It can never lift an admin's pause, halt a contract, upgrade, or move funds.

**3. Admin controls (manual).** The admin (the deployer at launch, then a multisig Safe after the handover) can pause or unpause anything, halt a contract fully, change limits and upgrade.

| Contract | Pause (guardian or admin) stops | Keeps running | Admin halt |
| --- | --- | --- | --- |
| Looping vault (`contracts/core`) | Deposits, redemption requests, new borrowing, minting and staking | De-levers, repayments, unstake claims, paying withdrawals already requested | Stops everything, for a contract fault |
| Pool treasuries (`contracts/hooks`) | Minting at $1, LP deposits, keeper moves | Swaps on the pool path | Swaps revert; LP exits continue |

Only the admin can unpause a pool, so a compromised guardian key can stop things but never restart them. Every pause, unpause and role change raises its own alert (`GUARDIAN_PAUSED`, `GUARDIAN_EMERGENCY_PAUSE`, `SETTINGS_PAUSED_BY_ADMIN`).

## Adding alerts and channels

The system is built to grow, and we welcome requests from partners.

- **New alerts:** each check is a small function that returns findings with a code and a level, so a new risk signal is a contained change with its own tests. Candidates we can add on request include partner-specific exposure limits, larger-trade or flow alerts on the pools, and liquidation-capacity alerts once external liquidation funding exists.
- **New thresholds:** most limits are runtime settings and change without a code release.
- **New channels:** the webhook already reaches any HTTPS endpoint, so Slack, Discord, PagerDuty, Opsgenie or email can be connected by configuration. Dedicated integrations, or a second chat per partner, are a small addition to the shared alerter.
- **Partner feeds:** we can route a chosen set of codes, for example every critical alert or every pool alert, to a channel or endpoint the partner owns.
- **Read access:** alert history can be exposed through a read-only API endpoint if partners prefer to pull rather than be pushed.

Tell us which signals and channels matter to you, and we will scope them.
