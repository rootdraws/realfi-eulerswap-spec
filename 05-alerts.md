# 5. Alerts and emergency controls

The monitor checks about 150 alert conditions every 12 seconds. Alerts go to Telegram, to any webhook a partner
names, and to a dead-man health check. The full list is in [`RISK-ALERTS.md`](sources/realfi-structures/RISK-ALERTS.md).

| Code | Path |
|---|---|
| Alert levels and delivery | [`alerts.ts`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/packages/shared/src/alerts.ts), [`telemetry.ts`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/packages/shared/src/telemetry.ts) |
| Thresholds | [`runtime.json`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/deploy/configs/mainnet/runtime.json) |

## Actions the services take on their own

1. The keeper de-levers the loop vault from 78% back to 70%, a quarter of the debt per transaction
   ([`services/keeper/src/loop`](https://github.com/alphagrowth/RealFiStructures/tree/fb29ef6d1aab554e78905a6410e03ef03ad00456/services/keeper/src/loop)).
2. The guardian pauses the vault at 85%, or when the monitor cannot read the chain
   ([`guardian.ts`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/services/positionMonitor/src/build1/guardian.ts)).
3. Only the admin can unpause a pool, halt a contract or upgrade.

A pause blocks new risk but leaves every exit that reduces risk open.

## Not monitored yet

- No service watches the EulerSwap pools yet. The checks to add are each pool's loan health, the cash left in its borrow
  vault, and how long RealFi takes to repay.
- None of our repos (RealFiStructures, ag-euler, alphastructures) sets up Hypernative or another outside monitor.
