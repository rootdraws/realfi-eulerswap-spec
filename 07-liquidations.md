# 7. Liquidations

## How Euler liquidates

Anyone may liquidate an unhealthy loan in our vaults. Euler needs no whitelist and no auction.[^liq]

- **When:** a loan passes its liquidation line (92% against sUSDrf, 95% against USDrf).
- **What the liquidator gets:** it repays some debt and receives collateral worth more than that debt.
- **The bonus:** it equals how far the loan has fallen past healthy, capped at 15% in all five vaults. A loan just past
  its line pays a small bonus, and a deeper one pays more. It is never a fixed 5%.
- **Cool-off:** 1 second after a loan was last healthy, so a liquidation can land in the next block.

## What a liquidator must solve

A liquidator who seizes sUSDrf ends up holding sUSDrf, and it needs USDrf or USDC to repay the loan. sUSDrf unstakes to
USDrf only after a 7-day cooldown, unless RealFi lists the liquidator for instant unstaking.

| Loan | Collateral seized | Repaid in | How the liquidator gets the repay token |
|---|---|---|---|
| USDrf from eUSDrf-1 or eUSDrf-2 | sUSDrf | USDrf | RealFi's instant unstake, if RealFi lists it; or the sUSDrf to USDrf pools |
| USDC from eUSDC-143 or eUSDC-69 | sUSDrf | USDC | the sUSDrf to USDC pools |
| USDC from eUSDC-143 or eUSDC-69 | USDrf | USDC | the USDrf to USDC pools, or RealFi's redemption, which waits on RealFi |

## Fabio's liquidator (Build 3)

Fabio's liquidator funds itself inside one transaction:[^b3]

1. It liquidates the loan and takes the sUSDrf.
2. It instant-unstakes only as much sUSDrf as the repayment needs. RealFi must list it as a StakeDesk liquidator.
3. It repays the USDrf debt and sends every leftover token to the profit receiver in the same call.

It holds nothing between transactions, and a liquidation that would not end in profit reverts. It handles only sUSDrf
collateral against USDrf debt on Euler: its admin cannot enable a pair with USDC debt. Loans of USDC need
another liquidator, or a route from sUSDrf or USDrf to USDC.

RedStone Settle, which would give a whitelisted liquidator the first chance in the same block, is not built yet.

## Funding liquidations with outside capital

Three designs exist. None is built.

| Design | How it works | Risk to the capital holder |
|---|---|---|
| Allowance | The holder approves our liquidator to draw from its wallet, and the liquidator returns the money plus profit | The approval stays open between liquidations, so a bug or stolen key could draw without returning |
| Flash-loan draw | A shared contract lends to the liquidator only inside one transaction, and reverts the whole transaction unless more money than it lent is back by its end | Nothing leaves for longer than one transaction, and every draw returns a profit |
| Lend to the pools' vaults | The holder deposits USDC or USDrf into the Euler vaults the EulerSwap pools borrow from; any liquidator sells seized collateral into the pools | The holder is an ordinary Euler lender: it earns the borrow rate and carries Euler's lender risk |

On the call of 2026-11-25, Fabio described the flash-loan draw: "we only do a drawdown in the event that in the exact
same block you guys get more money returned." He called it the most secure of the first two, because the contract
enforces the return on chain. The third design
is the one this spec adds: the capital earns between liquidations instead of waiting idle, and every liquidator, not only
ours, can use it.

[^liq]: Euler's liquidation code: `euler-vault-kit/src/EVault/modules/Liquidation.sol` lines 120 to 150 (the bonus is one minus the loan's health score, floored by `maxLiquidationDiscount`). Read at block 26,496,053: `maxLiquidationDiscount()` 1500 and `liquidationCoolOffTime()` 1 on eUSDrf-1, eUSDrf-2 and eUSDC-143.
[^b3]: `RealFiStructures/docs/AUDIT-NOTES.md` sections 4.1 and 4.2.
