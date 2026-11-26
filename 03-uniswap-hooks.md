# 3. Uniswap v4 hooks

| Hook | Pool | Base | External audit |
|---|---|---|---|
| `USDrfPoolHook` + `USDrfPoolTreasury` | USDrf/USDC | OZ `ReHypothecationHook` v1.3.0-rc.0 | No |
| `SUSDrfPoolHook` + `SUSDrfPoolTreasury` | sUSDrf/USDrf | OZ `ReHypothecationHook` v1.3.0-rc.0 | No |
| EulerSwap v2 `UniswapHook` | the four pools in [08](08-eulerswap-pools.md) | Euler | Yes ([02](02-contracts-and-audits.md)) |

## Building on OZ Hooks:

| | OZ `ReHypothecationHook` | Fabio's hooks |
|---|---|---|
| Idle liquidity | One ERC-4626 vault per token | Up to 8 whitelisted vaults per token |
| Liquidity per swap | Full range | From the current price, sized to the LPs' holdings |
| Fee | None | Rises as the price falls below par |
| Buys above par | Filled by LPs | Minted (pool 1) or staked (pool 2) through RealFi |
| PoolManager lacks the token | Swap reverts | Paid in ERC-6909 claims |
| Upgrades | Not upgradeable | UUPS, admin only |
| First seed | Anyone | Admin only |

- Port from upstream commit `b5f10574`, every change listed: [`PORT.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/hooks/vendor/oz-uniswap-hooks/PORT.md)
- Hook entry point: [`USDrfPoolHook.sol` L30-L54](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/contracts/hooks/USDrfPoolHook.sol#L30-L54)
- Design, overrides and risks: [`AUDIT-NOTES.md`](https://github.com/alphagrowth/RealFiStructures/blob/fb29ef6d1aab554e78905a6410e03ef03ad00456/docs/AUDIT-NOTES.md) sections 3 and 6
- Accepted risk: front-running a RealFi loss booking on pool 2 costs LPs (section 3.5)

## EulerSwap `UniswapHook`

- Accepts only its own pool; refuses v4 liquidity and donations ([L125-L145](https://github.com/euler-xyz/euler-swap/blob/dd936d2baaacb9064cf919b1fb45ecaa002d2751/src/UniswapHook.sol#L125-L145)).
- Needs the input paid in before the swap ([L111](https://github.com/euler-xyz/euler-swap/blob/dd936d2baaacb9064cf919b1fb45ecaa002d2751/src/UniswapHook.sol#L111)); Fynd's router does ([09](09-routing-fynd.md)).
- Pays from the account's deposit, then borrows ([`FundsLib.sol` L41-L65](https://github.com/euler-xyz/euler-swap/blob/dd936d2baaacb9064cf919b1fb45ecaa002d2751/src/libraries/FundsLib.sol#L41-L65));
  Euler checks the loan at the end.
