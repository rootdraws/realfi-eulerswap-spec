# 7. Liquidations

## Euler settings

- Loans liquidate at 92% LTV against sUSDrf and 95% against USDrf.
- The bonus grows with how far a loan has fallen, up to 15%. It is not a fixed 5%.
- The cool-off is 1 second, so a liquidation can land in the next block.

The bonus formula is in Euler's [`Liquidation.sol`](https://github.com/euler-xyz/euler-vault-kit/blob/93a1de491531e54cbbcf0e5c8cacfe558f924867/src/EVault/modules/Liquidation.sol#L120-L150). The settings were read on chain at block 26,496,053.

Liquidators sell seized sUSDrf into the EulerSwap pools in the same transaction, routed by Fynd ([09](09-routing-fynd.md)).

## Fabio's liquidator

Build 3 runs each liquidation in one transaction ([`RealFiLiquidator.sol` L115-L188](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/liquidator/RealFiLiquidator.sol#L115-L188)).
RealFi lists it for instant unstake, so it turns the seized sUSDrf into USDrf, repays the debt, and sends the profit on.
It holds no inventory, and it reverts any liquidation that would not profit ([`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md)
section 4).

## Funding with outside capital

A shared contract lends capital to the liquidator inside one transaction. The transaction reverts unless more than the
loan comes back by its end. Fabio described it on the call of 2026-11-25: "we only do a drawdown in the event that in
the exact same block you guys get more money returned." It is not built yet.
