# 10. Testing

## The mainnet fork test

On 2026-11-25 we forked Ethereum from our own archive node at block 26,495,709 and built everything on the copy. Each
script refuses to run against anything but the fork.

| Step | Script | Result |
|---|---|---|
| 1. Fabio's three builds | `yarn workspace @realfi-structures/deploy deploy --env mainnet-fork` | All steps done |
| 2. RealFi's listings, signed as RealFi's list admin | [`realfi-list.sh`](sources/fork/realfi-list.sh) | Every listing passed |
| 3. The RWA Safe batch, signed as the Safe | [`safe-batch.sh`](sources/fork/safe-batch.sh) | Every call passed |
| 4. Lender deposits and pool cushions | [`load.sh`](sources/fork/load.sh) | 7.5M USDC and 3M USDrf lent; six 100k cushions |
| 5. Six EulerSwap pools | [`script/Pools.s.sol`](sources/fork/script/Pools.s.sol) | All six deployed |
| 6. One trade through two pools | [`split-swap.sh`](sources/fork/split-swap.sh) | See below |

### Results

| Test | Result |
|---|---|
| Quote 100k USDrf into each USDrf pool | 99,700 USDC: fair value less the 0.30% fee |
| Quote 100k sUSDrf into each sUSDrf pool | 125,984 USDC or USDrf: RealFi's rate less 0.30% |
| Sell 300k USDrf into each USDrf pool in one router call | Paid 598,200 USDC; each pool borrowed 299,100 USDC |
| Sell 700k USDrf into one pool | Reverted: the pool could take 400k |
| Sell 700k USDrf split across both clusters' pools in one call | Paid 697,900 USDC |
| Swap first, pay after, through the Universal Router | Reverted: Uniswap held no USDrf to hand the pool |

### What the fork test changed from the live settings

- **Profit receiver:** Fabio's mainnet config leaves it open; the fork run names the AlphaGrowth Safe.
- **Liquidation bonus check:** Fabio's deploy check expects eUSDrf-2's bonus to be at most 5%. The live vault allows up to
  15%, so the fork config accepts 15%.
- **Tokens:** test balances of USDC, USDrf and sUSDrf were written directly into the fork's storage.

## How to rerun

You need an Ethereum archive RPC, Node 22.13.0, Foundry and Fabio's repo built (`yarn setup`).

```sh
# the fork, on chain id 1
cd RealFiStructures/contracts && HARDHAT_CHAIN_ID=1 npx hardhat node --fork <archive rpc> --port 8547
# Foundry's calls need the shim in front of Hardhat 2
python3 sources/fork/rpc-shim.py &
# then the steps above, in order; sources/fork/README.md has the exact commands
```

## Fabio's own tests

Fabio's repo has unit, fork, fuzz and invariant suites for all three builds, and conformance tests that run the same
checks on his RealFi mocks and on RealFi's real Sepolia contracts. `RealFiStructures/README.md` lists the commands, and
`docs/AUDIT-NOTES.md` maps each property to its test.
