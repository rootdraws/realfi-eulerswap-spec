# 3. Uniswap v4 hooks

| Hook | Pool | Base | External audit |
|---|---|---|---|
| `USDrfPoolHook` + `USDrfPoolTreasury` | USDrf/USDC | OZ `ReHypothecationHook` v1.3.0-rc.0 | No |
| `SUSDrfPoolHook` + `SUSDrfPoolTreasury` | sUSDrf/USDrf | OZ `ReHypothecationHook` v1.3.0-rc.0 | No |
| EulerSwap v2 `UniswapHook` | the four pools in [08](08-eulerswap-pools.md) | Euler | Yes ([02](02-contracts-and-audits.md)) |

## Fabio's hooks against OZ `ReHypothecationHook`

| | OZ upstream | Fabio's hooks |
|---|---|---|
| Idle liquidity | One ERC-4626 vault per token | Treasury across up to 8 whitelisted vaults per token |
| JIT range | Full range | Slice from the current price, sized from the LPs' book |
| Fee | None | Dynamic sell fee below par, path-averaged (`BaseOverrideFee`) |
| Buy above par | Fills from LPs | Mints USDrf (pool 1) or stakes sUSDrf (pool 2) through RealFi |
| PoolManager short of a token | Real tokens only | ERC-6909 claims, redeemed later |
| Upgrades | None | UUPS; admin, same contract id, higher `VERSION` |
| Seeding | Open | Admin-only first seed |

Sources: `contracts/hooks/USDrfPoolHook.sol` lines 30 to 54; port diff in `hooks/vendor/oz-uniswap-hooks/PORT.md`
(upstream commit `b5f10574`, file hashes); overrides in `AUDIT-NOTES.md` section 6; design in sections 3.1 to 3.5.

Accepted risk on pool 2: a swapper who front-runs a RealFi loss booking takes ~$261 from a 60k/60k pool per 0.5% loss
(`AUDIT-NOTES.md` section 3.5).

## EulerSwap `UniswapHook`

- Rejects foreign pool initialization, v4 liquidity and donations (`src/UniswapHook.sol` lines 125 to 145).
- Takes the input from the PoolManager mid-swap (line 111), so routers must settle input first; Fynd's router does
  ([09](09-routing-fynd.md)).
- Pays from the account's supply vault, then borrows (`src/libraries/FundsLib.sol` lines 41 to 65); health is checked
  at the end of the EVC call.
