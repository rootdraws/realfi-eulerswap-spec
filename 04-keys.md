# 4. Keys and permissions

## AlphaGrowth Safe [`0x4f894Bfc9481110278C356adE1473eBe2127Fd3C`](https://etherscan.io/address/0x4f894Bfc9481110278C356adE1473eBe2127Fd3C)

- 3 of 9 owners; no timelock, module or guard on Ethereum.
- Governor of all five vaults and both routers (`0x6eE2056AD473D46efAdCDA12529686D60d0E775B`, `0x3643E21087B7a6D3128AB4Ba35310ba0E7628504`), and fee receiver.
- Governor powers: `euler-vault-kit/src/EVault/modules/Governance.sol` lines 220 to 385. None moves deposits or
  collateral; the exposure is oracle and LTV choice.

Owners: `0x04805982AaA97e6632d1B73d0C004A6f0c02E2D9`, `0xF20cC34f6DEF058Bf79fd556d85cb951e31F1b61`,
`0xbCeAD0fDeE4C73e004FC509862fD5740D26D652d`, `0x513C1DC7c4ae6EC45e88eEE4808042B712CD5dC3`,
`0xcb629eDa290e94c7B1eE7D8114Ed1b58279EE980`, `0x7B6d72Fe8E487C823Bb5e41455c7Da0A99e9Fe77`,
`0xCfD4eAE5AD164dD02B41715Aa38E54ee68Af2955`, `0x2210dc066aacB03C9676C4F1b36084Af14cCd02E`,
`0x6e57181D6b4b7c138a6F956AD16DAF4f27FC5E04`.

## Builds 1 to 3

| Role | Holder | Can | Cannot |
|---|---|---|---|
| Admin | Deployer, then the Safe by `handover` | Upgrade (no timelock), set everything, halt, rescue | Remove a NAV source holding funds; replace a market with debt or collateral |
| Keeper (`EXECUTOR_ROLE`) | Server key | Loop, de-lever, settle batches, move pool USDrf among whitelisted vaults | Borrow past 70%, withdraw collateral past 85%, receive funds |
| Guardian | Server key, monitor only | Pause; lift its own pause | Lift an admin pause, halt, upgrade, move funds |
| Liquidator bot (`EXECUTOR_ROLE`) | Server key | Pick violators, sizes, whitelisted routes | Unlisted markets or routers; unprofitable liquidations |

Sources: `AUDIT-NOTES.md` sections 2.2, 3.2, 4.2; key rotation in `docs/RUNBOOK.md` "Rotating a key".

## EulerSwap pool accounts

The account owner sets price, fee, curve and managers (`euler-swap/src/EulerSwapManagement.sol`). Mainnet owner not yet
chosen.

## RealFi

Our contracts depend on RealFi's listings and roles; assumptions T1 to T8 and open item E32 (RealFi admin roles on
multisigs) in `AUDIT-NOTES.md` section 2.2.
