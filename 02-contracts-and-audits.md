# 2. Contracts and audits

## Live: Euler vaults

The vaults are Euler Vault Kit proxies from Euler's factory, deployed on 2026-11-20. The AlphaGrowth Safe, a 3 of 9
multisig, governs them ([04](04-keys.md)).[^v]

| Vault | Address | Cluster | Lends against |
|---|---|---|---|
| eUSDrf-1 | [`0x0F4E2AF3042FdECC3A10707252e8d617DB3B35c3`](https://etherscan.io/address/0x0F4E2AF3042FdECC3A10707252e8d617DB3B35c3) | RWA | RWA assets, sUSDrf |
| esUSDrf-1 | [`0x0Ee3807A399BFC5F58ed88faEf1a4A40F0EA0601`](https://etherscan.io/address/0x0Ee3807A399BFC5F58ed88faEf1a4A40F0EA0601) | RWA | collateral only |
| esUSDrf-2 | [`0x0e10056d88084D76A7df6CC612330aF1B60B0130`](https://etherscan.io/address/0x0e10056d88084D76A7df6CC612330aF1B60B0130) | RealFi | collateral only |
| eUSDrf-2 | [`0xEf240d6f1f2373bE393153F3125a3B514b204775`](https://etherscan.io/address/0xEf240d6f1f2373bE393153F3125a3B514b204775) | RealFi | sUSDrf, USDC |
| eUSDC-143 | [`0x3c089C265A86eCFB9BA6D5a3EFBE27eABa29E6c4`](https://etherscan.io/address/0x3c089C265A86eCFB9BA6D5a3EFBE27eABa29E6c4) | RealFi | sUSDrf, USDrf |

| Setting | Value |
|---|---|
| Borrow / liquidation LTV vs USDrf | 93% / 95% |
| Borrow / liquidation LTV vs sUSDrf | 90% / 92% |
| Borrow / liquidation LTV vs USDC | 95% / 96% |
| Supply caps | 5M USDC, 2M USDrf, 2M sUSDrf |
| USDrf IRM | 0%, 6.75% at 75% use, 25% at 100% |
| USDC IRM | 0%, 8.5% at 90% use, 20% at 100% |
| Max liquidation discount | 15% |
| Interest fee | 10%, to the Safe |

## Built, not deployed:

The contracts are upgradeable UUPS proxies with no timelock, built with solc 0.8.35 and OpenZeppelin 5.4.0. Fabio's
audit notes cover the design, roles, limits and findings: [`RealFiStructures/docs/AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md).

| Build | Contracts |
|---|---|
| 1. Loop vault | [`core/*`](https://github.com/alphagrowth/RealFiStructures/tree/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/core), [`adapters/realfi/RealFiAdapter.sol`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/adapters/realfi/RealFiAdapter.sol), `UnstakeEscrow.sol`, [`adapters/market/EulerMarketAdapter.sol`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/adapters/market/EulerMarketAdapter.sol) |
| 2. Pool hooks | [`hooks/USDrfPool{Hook,Treasury}.sol`](https://github.com/alphagrowth/RealFiStructures/tree/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/hooks), [`hooks/SUSDrfPool{Hook,Treasury}.sol`](https://github.com/alphagrowth/RealFiStructures/tree/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/hooks), `JitPoolQuoter.sol`, [`hooks/vendor/oz-uniswap-hooks/`](https://github.com/alphagrowth/RealFiStructures/tree/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/hooks/vendor/oz-uniswap-hooks) |
| 3. Liquidator | [`liquidator/RealFiLiquidator.sol`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/liquidator/RealFiLiquidator.sol) |

## Reviews

| Code | Reports |
|---|---|
| Builds 1 to 3 | No external audit. Internal reviews Oct 24 to Nov 18: 91 findings (3 H, 7 M, 39 L, 42 I), all H fixed; register in [`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md) section 8. Slither Oct 28. |
| Euler Vault Kit | [`euler-vault-kit/audits`](https://github.com/euler-xyz/euler-vault-kit/tree/master/audits): Certora, ChainSecurity, Spearbit, OpenZeppelin, Omniscia, Enigma Dark, yAudit, Cantina |
| Euler price adapters | [`euler-price-oracle/audits`](https://github.com/euler-xyz/euler-price-oracle/tree/master/audits): ChainSecurity, OpenZeppelin, Spearbit, Omniscia, yAudit, BailSec, Electisec, Cantina |
| EulerSwap v2 | [`euler-swap/audits`](https://github.com/euler-xyz/euler-swap/tree/master/audits): Cyfrin, ChainSecurity, Cantina |
| Uniswap v4 core | [`v4-core/docs/security/audits`](https://github.com/Uniswap/v4-core/tree/main/docs/security/audits): OpenZeppelin, Trail of Bits |
| OZ uniswap-hooks | [`uniswap-hooks/audits`](https://github.com/OpenZeppelin/uniswap-hooks/tree/master/audits): v1.0 and v1.1; `ReHypothecationHook` not covered |
| Tycho router | [`tycho-execution/docs/audits`](https://github.com/propeller-heads/tycho-execution/tree/main/docs/audits): 2025-03-04, 2025-08-05, 2026-05-15 |

Known limits:

- Rehypothecation swaps are limited in capacity when utilization is high.
- Eulerswap swaps are limited in capacity, when utilization is high, unless a separate USDC EVK Vault is designated as a primary swap venue.
- A RealFi pause of instant unstake blocks the de-lever but not an external liquidation; the keeper and monitor alert on it.

[^v]: Addresses: `ag-euler/contracts/realfi-ethereum/deployed-1.env`. Read at block 26,496,053: `LTVFull`, `caps`, `computeInterestRateView`, `maxLiquidationDiscount`, `interestFee`, `governorAdmin`.
