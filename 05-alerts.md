# 5. Alerts and emergency controls

Fabio's alert system is described in full in
[`sources/realfi-structures/RISK-ALERTS.md`](sources/realfi-structures/RISK-ALERTS.md): about 150 alert codes, checked
every 12 seconds, sent to Telegram, to any webhook a partner names, and to a dead-man health check.[^alerts]

## What acts without a person

1. **The keeper de-levers.** Past 78%, it unwinds the loop vault to 70%, a quarter of the debt per transaction.
2. **The guardian pauses.** At 85%, or when the monitor cannot see the chain, it pauses the vault.
3. **The admin decides the rest.** Only the admin unpauses a pool, halts a contract or upgrades.

A pause blocks new risk and keeps every exit that lowers it open.

## Not covered yet

- **The EulerSwap pools.** The checks to add are each pool's loan health, the room left in the vault it borrows from, and
  how long RealFi takes to repay its loans.
- **Outside monitoring.** None of our three repos (RealFiStructures, ag-euler, alphastructures) sets up Hypernative or
  another outside monitor.

[^alerts]: `RealFiStructures/docs/RISK-ALERTS.md` at `fb29ef6`; tick length in `deploy/configs/mainnet/runtime.json` (`tickMs` 12000).
