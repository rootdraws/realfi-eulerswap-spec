# 7. Liquidations

## Euler's liquidation settings

- Loans liquidate at 92% LTV against sUSDrf and 95% against USDrf.
- The bonus grows with how far the loan has fallen, up to 15%. It is not a fixed 5%.
- The cool-off is 1 second, so a liquidation can land in the next block.

The bonus formula is in [`Liquidation.sol`](https://github.com/euler-xyz/euler-vault-kit/blob/93a1de491531e54cbbcf0e5c8cacfe558f924867/src/EVault/modules/Liquidation.sol#L120-L150). The settings were read on chain at block 26,496,053.

## Funding a liquidation in one transaction

Each route lends the liquidator the repayment token and reverts unless it is paid back by the end of the transaction.

| Route | How it works | Status | Source |
|---|---|---|---|
| Build 3 | RealFi lists it for instant unstake. Inside one EVC call it liquidates, unstakes the seized sUSDrf, repays and sends the profit on. | Built | [`RealFiLiquidator.sol` L115-L188](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/liquidator/RealFiLiquidator.sol#L115-L188) |
| EulerSwap flash swap | The pool pays out USDrf or USDC first. The liquidator liquidates and pays the pool back with the seized sUSDrf in the callback. | Available; not tested for liquidation | [`EulerSwap.sol` L122-L153](https://github.com/euler-xyz/euler-swap/blob/dd936d2baaacb9064cf919b1fb45ecaa002d2751/src/EulerSwap.sol#L122-L153) |
| Rehypothecation pools, Uniswap v4 flash accounting | The liquidator takes USDrf from the pool, liquidates, and settles the sUSDrf before its Uniswap call ends. | By the code; not tested | [`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md) section 6 |
| Outside capital | A shared contract lends to the liquidator and reverts unless more than the loan comes back. | Not built | Call of 2026-11-25 |

- An EulerSwap `beforeSwap` hook can limit which callers may flash swap ([`SwapLib.sol` L90-L95](https://github.com/euler-xyz/euler-swap/blob/dd936d2baaacb9064cf919b1fb45ecaa002d2751/src/libraries/SwapLib.sol#L90-L95)).
- On outside capital, from the call of 2026-11-25: "we only do a drawdown in the event that in the exact same block you guys get more money
  returned."
