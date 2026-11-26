# 3. The Uniswap v4 hooks

| Hook | Pool | Built on | Written by | Outside audit |
|---|---|---|---|---|
| `USDrfPoolHook` and `USDrfPoolTreasury` | USDrf/USDC (pool 1) | OpenZeppelin `ReHypothecationHook` | Fabio | No |
| `SUSDrfPoolHook` and `SUSDrfPoolTreasury` | sUSDrf/USDrf (pool 2) | OpenZeppelin `ReHypothecationHook` | Fabio | No |
| EulerSwap v2 (`UniswapHook.sol`) | the six lender-funded pools | Euler's own code | Euler | Yes, six reports (see [02](02-contracts-and-audits.md)) |

## Fabio's pool hooks (Build 2)

Each pool is a hook plus a treasury that holds the LPs' money, split to fit the 24 KB limit.[^hook]

- **Between swaps,** the LPs' money sits in lending vaults and earns: pool 1's USDC in Aave's USDC wrapper and its USDrf in
  eUSDrf-2, pool 2's USDrf in eUSDrf-1 and its sUSDrf in esUSDrf-1.
- **On a buy above $1,** the hook mints new USDrf 1:1 through RealFi instead of selling the LPs' USDrf. Pool 2 does the
  same at sUSDrf's fair value, staking new sUSDrf.
- **On a sell below $1,** the seller pays a fee that rises with the discount, up to 5%.
- **When Uniswap holds no USDrf,** the hook takes what it is owed as Uniswap IOUs and turns them into tokens later.

Money leaves a treasury only to vaults the admin listed (at most eight per token), to Uniswap during a swap, or to an
LP who is leaving.

### Where the design comes from

Both pool hooks extend OpenZeppelin's `ReHypothecationHook`, from OpenZeppelin's uniswap-hooks library at tag
v1.3.0-rc.0 (commit `b5f10574`). They do not use OpenZeppelin's `LimitOrderHook`: that hook rests limit orders as
liquidity in the pool, and AlphaGrowth's shMON exit desk on Monad uses it for its USDC pool. `ReHypothecationHook`
instead keeps liquidity in outside vaults and adds it to the pool only for the length of one swap.[^oz]

| Part | OpenZeppelin's `ReHypothecationHook` | Fabio's hooks |
|---|---|---|
| Where liquidity waits | One ERC-4626 vault per token | A treasury contract that spreads each token across up to eight listed vaults |
| The position for a swap | The full price range | A slice of the pool's range that starts at the current price, sized from the LPs' holdings |
| Fees | None of its own | A sell fee that rises as the price falls below $1, averaged over the price path the sale crosses, through OpenZeppelin's `BaseOverrideFee` |
| A buy above $1 | Fills from the LPs | Mints new USDrf 1:1 through RealFi instead |
| When Uniswap lacks the token | Moves real tokens only | Takes Uniswap IOUs for the shortfall and turns them into tokens later |
| Upgrades | None; a plain contract | Behind an upgradeable proxy: an upgrade needs the admin, the same contract name and a higher version |
| Seeding and LP deposits | Open to anyone | The first seed is admin-only, and deposits stop while paused |

The port to upgradeable contracts is listed line by line in `hooks/vendor/oz-uniswap-hooks/PORT.md`.

### Review status

OpenZeppelin never audited `ReHypothecationHook`, the base these hooks extend; it audited `BaseHook`, `BaseOverrideFee`
and `CurrencySettler` in v1.0 and v1.1. One accepted risk is specific to pool 2: someone who sees RealFi book a loss can
sell sUSDrf to the LPs at the old price first, about $261 on a 60k/60k pool for a 0.5% loss.

## Euler's EulerSwap hook

Every EulerSwap pool is its own Uniswap v4 hook. It quotes from a curve and trades from an Euler account instead of
holding liquidity in Uniswap.[^es]

- It refuses to be set up for any pool but its own, and refuses ordinary Uniswap liquidity and donations.
- On a swap, it pulls the input token out of Uniswap, deposits it in Euler, and pays the output from the account's Euler
  deposit or a new loan.
- Euler checks the account's health once, at the end, and the swap reverts if the loan limit is broken.

Routers must pay the input in before the swap. Fynd's router does ([09-routing-fynd.md](09-routing-fynd.md)).

[^oz]: `RealFiStructures/contracts/hooks/USDrfPoolHook.sol` lines 30 to 54 (imports and extends `ReHypothecationHookUpgradeable`); `contracts/hooks/vendor/oz-uniswap-hooks/PORT.md`; OpenZeppelin's `uniswap-hooks/src/general/ReHypothecationHook.sol` and `LimitOrderHook.sol`; a search of `contracts/hooks/` finds no use of `LimitOrderHook`. The Monad exit desk's hook: `0x94Df2bffA788BBd918179f4CCB5A22DbAD7e1040` on Monad, OpenZeppelin `LimitOrderHook` from uniswap-hooks 1.3.0.
[^hook]: `RealFiStructures/docs/AUDIT-NOTES.md` sections 3.1 to 3.5 and 6.
[^es]: `euler-swap/src/UniswapHook.sol`: hook permissions lines 125 to 145; the input pulled with `poolManager.take` at line 111. Payout order: `euler-swap/src/libraries/FundsLib.sol` lines 41 to 65.
