# 4. Keys and permissions

## The AlphaGrowth Safe

One Safe governs every RealFi lending vault on Ethereum: `0x4f894Bfc9481110278C356adE1473eBe2127Fd3C`.[^safe]

- **Signers:** any 3 of 9 owners sign a transaction.
- **Timelock:** none on Ethereum. A signed transaction takes effect at once.
- **Modules and guard:** none. Only the owners' signatures can move the Safe.

Owners: `0x04805982AaA97e6632d1B73d0C004A6f0c02E2D9`, `0xF20cC34f6DEF058Bf79fd556d85cb951e31F1b61`, `0xbCeAD0fDeE4C73e004FC509862fD5740D26D652d`, `0x513C1DC7c4ae6EC45e88eEE4808042B712CD5dC3`, `0xcb629eDa290e94c7B1eE7D8114Ed1b58279EE980`, `0x7B6d72Fe8E487C823Bb5e41455c7Da0A99e9Fe77`, `0xCfD4eAE5AD164dD02B41715Aa38E54ee68Af2955`, `0x2210dc066aacB03C9676C4F1b36084Af14cCd02E`, `0x6e57181D6b4b7c138a6F956AD16DAF4f27FC5E04`.

What the Safe controls on the Euler side:

- It governs all five RealFi vaults, so it sets their borrow limits, liquidation lines, caps, rate curves and the
  liquidation bonus ceiling.
- It governs both price routers, so it chooses which price feed values USDrf and sUSDrf.
- It receives the 10% interest fee from every vault.

No governor function in Euler's vault code moves deposits or collateral to the Safe. The Safe could still hurt lenders
by setting a wrong price feed or a loose borrow limit, which is why three signers must agree.

## Fabio's builds

Each build uses the same four roles. At launch the deployer holds the admin role, and a one-way handover command moves it
to the Safe.[^roles]

| Role | Held by | Can | Cannot |
|---|---|---|---|
| Admin | The deployer, then the Safe | Upgrade every contract (no timelock), change every setting, halt, unpause, rescue tokens | Remove a price source that still reports funds, or swap a market that still holds debt or collateral |
| Keeper | A server key run by the keeper service | Loop and de-lever the vault, settle withdrawals, move pool money between listed vaults | Borrow past the 70% target, withdraw collateral past 85%, move funds to itself, act while halted |
| Guardian | A server key held only by the monitor | Pause, and lift only its own pause | Lift the admin's pause, halt, upgrade, move funds |
| Liquidator bot | A server key run by the liquidator service | Choose which loans to liquidate, how much, and which listed router swaps | Use markets or routers the admin did not list, or finish a liquidation without profit |

A stolen guardian key can stop things but never restart them. A stolen keeper or bot key is replaced by the admin
granting the role to a new address and revoking the old one (`docs/RUNBOOK.md`, "Rotating a key").

## The EulerSwap pools

Each pool trades from its own Euler sub-account, and the account's owner controls it.[^pool]

- The owner can change the pool's price, fee and curve, or close it, and can add managers who may change those too.
- The owner can withdraw the account's collateral, as long as its loan stays healthy.
- Nobody else can move the account's money.

Who owns the pool accounts on mainnet is not decided. On the fork test, one test address owns all six.

## RealFi's keys

RealFi's own admins decide who may hold, mint and unstake USDrf and sUSDrf. Fabio's audit notes list what our contracts
need from them (`docs/AUDIT-NOTES.md`, the T1 to T8 assumptions). The one that matters most here: RealFi's admin roles
must be held by multisigs before money goes in (open item E32).

[^safe]: Read at block 26,496,053: `getThreshold()` 3, `getOwners()` the nine above, `getModulesPaginated` empty, guard storage slot zero. `governorAdmin()` and `feeReceiver()` of all five vaults, and `governor()` of both routers, return the Safe. Euler's governor functions are listed in `euler-vault-kit/src/EVault/modules/Governance.sol` lines 220 to 385; `convertFees` pays only the interest fee.
[^roles]: `RealFiStructures/docs/AUDIT-NOTES.md` sections 2.2, 3.2 and 4.2; `deploy/configs/mainnet/deploy.json` `roles`; `docs/DEPLOY.md` (the handover command).
[^pool]: `euler-swap/src/EulerSwapManagement.sol`: `setManager` and `reconfigure`. The pool acts only as an EVC operator of its own account.
