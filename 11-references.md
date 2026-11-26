# 11. References

## Ethereum addresses

| What | Address |
|---|---|
| AlphaGrowth Safe (governor and fee receiver) | `0x4f894Bfc9481110278C356adE1473eBe2127Fd3C` |
| AlphaGrowth deployer | `0x501107fe590c8F9b81c00b81867fD19e0d9c0253` |
| USDrf | `0xD75647217206052F6090678905026AA374431563` |
| sUSDrf | `0x8f4507d315acf966Fe21F9f4feE4F7e1A6d4c400` |
| USDC | `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` |
| eUSDrf-1 (RWA cluster) | `0x0F4E2AF3042FdECC3A10707252e8d617DB3B35c3` |
| esUSDrf-1 (RWA cluster) | `0x0Ee3807A399BFC5F58ed88faEf1a4A40F0EA0601` |
| eUSDC-69 (RWA cluster) | `0x2a356443FeE07703266066c6Bb1B11b82d8246AD` |
| esUSDrf-2 (RealFi cluster) | `0x0e10056d88084D76A7df6CC612330aF1B60B0130` |
| eUSDrf-2 (RealFi cluster) | `0xEf240d6f1f2373bE393153F3125a3B514b204775` |
| eUSDC-143 (RealFi cluster) | `0x3c089C265A86eCFB9BA6D5a3EFBE27eABa29E6c4` |
| RealFi cluster router | `0x6eE2056AD473D46efAdCDA12529686D60d0E775B` |
| RWA cluster router | `0x3643E21087B7a6D3128AB4Ba35310ba0E7628504` |
| USDrf price adapter | `0x0d6482227EEBe29a1a4fED0866ddcdd5DC4BAa45` |
| sUSDrf price adapter | `0x38BB6aA9756419D3F4f13545A50951864a65344a` |
| RedStone USDrf feed | `0xfd73818CE104EdECb96fb902Bf5ef7Ec840AFD08` |
| RedStone sUSDrf feed | `0x740C49409bde0a1D74274Faf28abfe09Cf83Ba5A` |
| USDrf rate curve | `0xDba27997c6280D3203AEBD5e2D9e88b79752e9C0` |
| USDC rate curve (shared with eUSDC-69) | `0x218e8DAcd5cDf9CFaDa012B7d412193EDc857514` |
| RealFi access list | `0xE7Ab45F75cfDf8E6B0161957759a5faC87b7ACB0` |
| RealFi allowlist | `0x763267fa41Fc4a1aE5E6DC0da410815fBcA96b53` |
| RealFi StakeDesk | `0x0CDf9283D79E7fFd421F8065f207dFeA6C41dA3b` |
| Ethereum Vault Connector | `0x0C9a3dd6b8F28529d72d7f9cE918D493519EE383` |
| EulerSwap v2 factory | `0xD05213331221fAB8a3C387F2affBb605Bb04DF5F` |
| EulerSwap v2 periphery | `0xD3a349EE0A21eA0A7E9513ac236ae614b5FD513E` |
| Uniswap v4 PoolManager | `0x000000000004444c5dc75cB358380D2e3dE08A90` |
| Uniswap Universal Router used in the fork test | `0x66a9893cC07D91D95644AEDD05D03f95e1dBA8Af` |
| Permit2 | `0x000000000022D473030F116dDEE9F6B43aC78BA3` |

## Fork-only addresses

These exist only on the 2026-11-25 fork and will differ on mainnet.

| Pool | Address | Account |
|---|---|---|
| RealFi A, sUSDrf <> USDC | `0xBdAa1a39cF93f9dC0Ed324748494c21f6986E8A8` | `0x000000000000000000000000000000000000Aa07` |
| RealFi B, sUSDrf <> USDrf | `0xe39EA50e9243ac2b9AFC9E6318791466B7A128A8` | `0x000000000000000000000000000000000000aa08` |
| RWA A, sUSDrf <> USDC | `0xaE77E5B69Ef6BffaD81f9c1AE92E560Eb0D928a8` | `0x000000000000000000000000000000000000aA09` |
| RWA B, sUSDrf <> USDrf | `0x2E01bE201f33B7E70Ff6ba2C29d7641Cf6f768a8` | `0x000000000000000000000000000000000000Aa0A` |

## Documents

| Document | Where |
|---|---|
| Fabio's audit notes, roles and findings | [`RealFiStructures/docs/AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md) |
| Alerts and emergency controls | [`RealFiStructures/docs/RISK-ALERTS.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/RISK-ALERTS.md) |
| Deploy parameters | [`RealFiStructures/docs/DEPLOY.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/DEPLOY.md) |
| Operator runbook | [`RealFiStructures/docs/RUNBOOK.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/RUNBOOK.md) |
| Open questions for RealFi and us | [`RealFiStructures/docs/OPEN-ITEMS.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/OPEN-ITEMS.md) |
| Euler vault deploy script | `ag-euler/contracts/realfi-ethereum/deploy.sh` |
| EulerSwap source and audits | [euler-xyz/euler-swap](https://github.com/euler-xyz/euler-swap) |
| Tycho router source and audits | [propeller-heads/tycho-execution](https://github.com/propeller-heads/tycho-execution) |
