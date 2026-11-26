# 2. Contracts and audits

## What is live on Ethereum

Five Euler vaults, deployed 2026-11-20 by AlphaGrowth's deployer `0x501107fe590c8F9b81c00b81867fD19e0d9c0253` and since
handed to the AlphaGrowth Safe. They run Euler's own audited vault code (the Euler Vault Kit), created through Euler's
factory, so no contract here was written by us.[^vaults]

| Vault | Address | Cluster | What it does |
|---|---|---|---|
| eUSDrf-1 | `0x0F4E2AF3042FdECC3A10707252e8d617DB3B35c3` | Euler's Mainnet RWA cluster | Lends USDrf against the RWA cluster's assets and sUSDrf |
| esUSDrf-1 | `0x0Ee3807A399BFC5F58ed88faEf1a4A40F0EA0601` | Mainnet RWA cluster | Holds sUSDrf collateral; lends nothing |
| esUSDrf-2 | `0x0e10056d88084D76A7df6CC612330aF1B60B0130` | RealFi cluster | Holds sUSDrf collateral; lends nothing |
| eUSDrf-2 | `0xEf240d6f1f2373bE393153F3125a3B514b204775` | RealFi cluster | Lends USDrf against sUSDrf and USDC |
| eUSDC-143 | `0x3c089C265A86eCFB9BA6D5a3EFBE27eABa29E6c4` | RealFi cluster | Lends USDC against sUSDrf and USDrf |

The RealFi cluster prices through its own Euler router `0x6eE2056AD473D46efAdCDA12529686D60d0E775B`. The RWA cluster's
router `0x3643E21087B7a6D3128AB4Ba35310ba0E7628504` belonged to the AlphaGrowth Safe before RealFi was added.

| Setting | Value |
|---|---|
| Borrow limit and liquidation line, against USDrf | 93% and 95% |
| Borrow limit and liquidation line, against sUSDrf | 90% and 92% |
| Borrow limit and liquidation line, against USDC (RealFi cluster) | 95% and 96% |
| Deposit caps | 5M USDC, 2M USDrf, 2M sUSDrf per vault |
| USDrf borrow rate | 0% unused, 6.75% a year at 75% use, 25% at 100% |
| USDC borrow rate (RealFi cluster) | 0% unused, 8.5% a year at 90% use, 20% at 100% |
| Liquidation bonus | Grows with how unhealthy a loan is, up to 15% |
| Interest fee | 10% of interest, to the AlphaGrowth Safe |

All five vaults held nothing at block 26,496,053.

## What is built but not deployed

Fabio's three builds live in [alphagrowth/RealFiStructures](https://github.com/alphagrowth/RealFiStructures). None is
on mainnet yet: the repo's mainnet deployment record is empty.

| Build | Contracts | Lines | Upgradeable |
|---|---|---|---|
| 1. Loop vault | `core/Vault.sol`, `WithdrawalHandler.sol`, `StrategyController.sol`, `StrategyControllerSettings.sol`, `NavCalculator.sol`, `adapters/realfi/RealFiAdapter.sol`, `UnstakeEscrow.sol`, `adapters/market/EulerMarketAdapter.sol` | about 3,000 | Yes, behind proxies, with no timelock |
| 2. Pool hooks | `hooks/USDrfPoolHook.sol`, `USDrfPoolTreasury.sol`, `SUSDrfPoolHook.sol`, `SUSDrfPoolTreasury.sol`, `JitPoolQuoter.sol`, and OpenZeppelin's uniswap-hooks 1.3.0-rc.0 ported to upgradeable | about 4,600, plus interfaces | Yes, with no timelock |
| 3. Liquidator | `liquidator/RealFiLiquidator.sol` | about 750 | Yes, with no timelock |

How each works, what each role can and cannot do, every known limitation and every finding are in Fabio's audit notes,
`docs/AUDIT-NOTES.md` (736 lines). The EulerSwap pools in [08-eulerswap-pools.md](08-eulerswap-pools.md) are Euler's
contract, deployed by Euler's factory, with only our settings.

## Who has reviewed what

| Code | Reviews |
|---|---|
| Fabio's three builds | **No outside audit yet.** Fabio's internal reviews (Oct 24, Oct 26, Oct 28, Nov 7, Nov 15, Nov 18) logged 91 findings: 3 high, 7 medium, 39 low, 42 informational. All 3 highs are fixed. Slither ran on Oct 28. |
| Euler Vault Kit (every lending vault) | Certora, ChainSecurity, Spearbit, OpenZeppelin, Omniscia, Enigma Dark, yAudit, and a Cantina competition |
| Euler price oracle adapters (the RedStone adapters) | ChainSecurity, OpenZeppelin, Spearbit, Omniscia, yAudit, BailSec, Electisec, and a Cantina competition |
| EulerSwap v2 (the six pools) | Cyfrin (2025-05-26), ChainSecurity, Cantina, and others: six reports in Euler's repo |
| Uniswap v4 core | OpenZeppelin and Trail of Bits, plus others |
| Tycho router and executors (Fynd's router) | Three audits in Propeller Heads' repo (2025-03-04, 2025-08-05, 2026-05-15) |
| ushMON, our closest earlier contract | An outside audit on 2026-11-15 found no high issue; eleven later issues were all settled |

The two internal findings not fully closed:

- **B2-H-01:** a round trip through pool 1 can pay a small amount when a lending venue is nearly empty. Fabio accepted
  it: at most about $750 a trip, and at $1 the attacker loses.
- **B1-M-05:** a RealFi pause of instant unstaking stops our de-lever but not an outside liquidation of the loop vault.
  It is partly fixed: the keeper and monitor page on every such pause.

[^vaults]: Addresses: `ag-euler/contracts/realfi-ethereum/deployed-1.env`. Settings read on chain at block 26,496,053: `LTVFull`, `caps`, `maxLiquidationDiscount` (1500), `interestRateModel` rates through `computeInterestRateView`, `feeReceiver`, `governorAdmin`, `totalAssets` (0).
