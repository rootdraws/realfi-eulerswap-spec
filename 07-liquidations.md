# 7. Liquidations

## Euler's settings

- **Liquidation lines:** 92% against sUSDrf, 95% against USDrf.
- **Bonus:** scales with how far the loan has fallen, capped at 15%. It is not a fixed 5%.
- **Cool-off:** 1 second.[^liq]

Seized sUSDrf sells into the EulerSwap pools in the same transaction, through Fynd ([09](09-routing-fynd.md)).

## Fabio's liquidator

Build 3 instant-unstakes the seized sUSDrf as a RealFi-listed liquidator, repays the USDrf debt and sweeps the profit,
in one transaction. It holds no inventory, and an unprofitable liquidation reverts.[^b3]

## Funding liquidations with outside capital

A shared contract lends the capital to the liquidator inside one transaction, and reverts unless more than it lent is
back by the end.

Fabio, on the call of 2026-11-25: "we only do a drawdown in the event that in the exact same block you guys get more
money returned." This contract is not built yet.

[^liq]: `euler-vault-kit/src/EVault/modules/Liquidation.sol` lines 120 to 150. Read at block 26,496,053: `maxLiquidationDiscount()` 1500 and `liquidationCoolOffTime()` 1 on eUSDrf-1, eUSDrf-2 and eUSDC-143.
[^b3]: `RealFiStructures/docs/AUDIT-NOTES.md` sections 4.1 and 4.2.
