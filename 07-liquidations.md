# 7. Liquidations

## How Euler liquidates

Anyone may liquidate an unhealthy loan in our vaults, with no whitelist and no auction.[^liq]

- **When:** a loan passes its liquidation line, 92% against sUSDrf or 95% against USDrf.
- **Bonus:** the liquidator gets collateral worth more than the debt it repays. The bonus grows with how far the loan
  has fallen, up to 15%. It is not a fixed 5%.
- **Timing:** a liquidation can land in the block after the loan turns unhealthy.

A liquidator who seizes sUSDrf needs USDrf or USDC to repay the loan. It sells the sUSDrf into the EulerSwap pools in the
same transaction, through Fynd ([09](09-routing-fynd.md)).

## Fabio's liquidator

Fabio's liquidator (Build 3) does the whole liquidation in one transaction and holds nothing between them. It
instant-unstakes the seized sUSDrf through RealFi, which lists it as a liquidator, repays the USDrf loan, and sends the
profit on. A liquidation that would not profit reverts.[^b3]

## Funding liquidations with outside capital

The capital sits in a shared contract that lends to the liquidator only inside one transaction. The whole transaction
reverts unless more money than was lent is back by its end, so the capital never leaves for longer than one transaction
and every draw returns a profit.

Fabio, on the call of 2026-11-25: "we only do a drawdown in the event that in the exact same block you guys get more
money returned." This contract is not built yet.

[^liq]: `euler-vault-kit/src/EVault/modules/Liquidation.sol` lines 120 to 150. Read at block 26,496,053: `maxLiquidationDiscount()` 1500 and `liquidationCoolOffTime()` 1 on eUSDrf-1, eUSDrf-2 and eUSDC-143.
[^b3]: `RealFiStructures/docs/AUDIT-NOTES.md` sections 4.1 and 4.2.
