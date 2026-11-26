# 4. Keys and permissions

## AlphaGrowth Safe [`0x4f894Bfc9481110278C356adE1473eBe2127Fd3C`](https://etherscan.io/address/0x4f894Bfc9481110278C356adE1473eBe2127Fd3C)

- Any 3 of its 9 owners can sign. It has no timelock, module or guard on Ethereum.
- It governs all five vaults and both routers, and it receives the interest fee.
- Its governor powers set oracles, LTVs, caps, rates and fees ([`Governance.sol`](https://github.com/euler-xyz/euler-vault-kit/blob/93a1de491531e54cbbcf0e5c8cacfe558f924867/src/EVault/modules/Governance.sol#L220-L398)). None of them can move
  deposits or collateral.

Owners: `0x04805982AaA97e6632d1B73d0C004A6f0c02E2D9`, `0xF20cC34f6DEF058Bf79fd556d85cb951e31F1b61`,
`0xbCeAD0fDeE4C73e004FC509862fD5740D26D652d`, `0x513C1DC7c4ae6EC45e88eEE4808042B712CD5dC3`,
`0xcb629eDa290e94c7B1eE7D8114Ed1b58279EE980`, `0x7B6d72Fe8E487C823Bb5e41455c7Da0A99e9Fe77`,
`0xCfD4eAE5AD164dD02B41715Aa38E54ee68Af2955`, `0x2210dc066aacB03C9676C4F1b36084Af14cCd02E`,
`0x6e57181D6b4b7c138a6F956AD16DAF4f27FC5E04`.

## Builds 1 to 3

| Role | Held by | Can | Cannot |
|---|---|---|---|
| Admin | The deployer, then the Safe after `handover` | Upgrade without a timelock, change any setting, halt, rescue tokens | Remove a NAV source that holds funds, or replace a market that has debt or collateral |
| Keeper | A server key | Loop, de-lever, settle withdrawals, and move pool USDrf between whitelisted vaults | Borrow past 70%, withdraw collateral past 85%, or receive funds |
| Guardian | A server key used only by the monitor | Pause, and lift its own pause | Lift the admin's pause, halt, upgrade, or move funds |
| Liquidator bot | A server key | Choose which loans to liquidate, how much, and which whitelisted route to use | Use unlisted markets or routers, or finish a liquidation without profit |

Roles are defined in [`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md) sections 2.2, 3.2 and 4.2. Key rotation is in
[`RUNBOOK.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/RUNBOOK.md), "Rotating a key".

## EulerSwap pool accounts

Each account's owner sets its pool's price, fee, curve and managers ([`EulerSwapManagement.sol`](https://github.com/euler-xyz/euler-swap/blob/dd936d2baaacb9064cf919b1fb45ecaa002d2751/src/EulerSwapManagement.sol#L139-L165)). The mainnet
owner is not chosen yet.

## RealFi

Our contracts depend on RealFi's listings and admin roles. The assumptions are listed in
[`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md) section 2.2, and open item E32 asks RealFi to hold its admin roles in
multisigs.
