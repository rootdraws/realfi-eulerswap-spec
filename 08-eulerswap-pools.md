# 8. The lender-funded EulerSwap pools

Six pools, three in each Euler cluster. Each buys a RealFi token and pays the seller with a loan from that cluster's
vault. They run Euler's EulerSwap v2, deployed by Euler on Ethereum, with only our settings.[^es]

| Pool | Buys | Pays | Collateral goes to | Loan comes from |
|---|---|---|---|---|
| RealFi A | USDrf | USDC | eUSDrf-2 | eUSDC-143 |
| RealFi B | sUSDrf | USDC | esUSDrf-2 | eUSDC-143 |
| RealFi C | sUSDrf | USDrf | esUSDrf-2 | eUSDrf-2 |
| RWA A | USDrf | USDC | eUSDrf-1 | eUSDC-69 |
| RWA B | sUSDrf | USDC | esUSDrf-1 | eUSDC-69 |
| RWA C | sUSDrf | USDrf | esUSDrf-1 | eUSDrf-1 |

## How one sale works

1. A seller sends USDrf into pool A.
2. The pool deposits it into eUSDrf-2, where it becomes the pool account's collateral.
3. The pool borrows USDC from eUSDC-143 and pays the seller.
4. Euler checks the account's loan once, at the end. If it breaks the 93% limit, the whole sale reverts.
5. Later, RealFi redeems the USDrf for USDC, and the USDC repays the loan.

Each pool trades from its own Euler sub-account, because one Euler account may owe only one vault at a time.

## Settings used on the fork

| Setting | Value | Why |
|---|---|---|
| Price | USDrf at $1; sUSDrf at RealFi's rate when the pool was made | Sellers get fair value |
| Curve | Flat | Every sale gets the same price, whatever its size |
| Fee | 0.30% | A test value; not decided for mainnet |
| Cushion | 100k of the bought token, deposited for each pool account | The loan limit is under 100%, so the account needs its own collateral |
| Fee receiver | None | Fees stay in the pool account |

The price does not follow sUSDrf's rate on its own. As the rate rises, the pool's owner must update it, or add a hook
that does, as the shMON exit desk on Monad does with its EulerSwap pool.

## What limits a pool's depth

Three things cap how much one pool can buy:

1. **The collateral vault's deposit cap.** Each USDrf and sUSDrf vault takes at most 2M. On the fork, the USDrf vaults
   held 1.6M, so pool A could buy only 400k of USDrf.
2. **The lending vault's cash.** A pool can borrow only what lenders have deposited and nobody else has borrowed.
3. **The cushion.** Pool A pays 99.7% of value but may borrow only 93% of it, so the pool account's own collateral
   must cover the gap. A bigger cushion lets a pool buy more before its loan limit stops it.

On the fork, EulerSwap's periphery (`getLimits`) reported these limits:

| Pool | Most it would take in |
|---|---|
| RealFi A and RWA A | 400k USDrf |
| RealFi B and RWA B | 1.8M sUSDrf |
| RealFi C and RWA C | 1.27M sUSDrf |

## What repays the loans

| Pool | Repaid by | How long it takes |
|---|---|---|
| A (USDrf in, USDC out) | RealFi redeeming the USDrf for USDC | Each mainnet redemption waits for RealFi's Safe to approve it, and RealFi has promised no deadline |
| B (sUSDrf in, USDC out) | Unstaking the sUSDrf, then redeeming the USDrf | 7 days, then the redemption wait |
| C (sUSDrf in, USDrf out) | Unstaking the sUSDrf | 7 days |

Until a loan is repaid, the lender earns the borrow rate on it. The pool account pays that interest out of its 0.30% fee
and its cushion.

## Access lists

USDrf and sUSDrf refuse a transfer unless the receiver is on RealFi's access list or is exempt. On the fork, RealFi's list
admin listed all six pools. On mainnet, RealFi must list each pool before it can trade.

[^es]: EulerSwap v2 on Ethereum: factory `0xD05213331221fAB8a3C387F2affBb605Bb04DF5F`, implementation `0x8B0E044E364F2cE913799d53b300e15A6974DC97` (`eulerSwapImpl()`), periphery `0xD3a349EE0A21eA0A7E9513ac236ae614b5FD513E` (euler-interfaces `addresses/1/EulerSwapAddresses.json`). Pool settings: [`sources/fork/script/Pools.s.sol`](sources/fork/script/Pools.s.sol). Redemption approval: `RealFiStructures/docs/OPEN-ITEMS.md` E7.
