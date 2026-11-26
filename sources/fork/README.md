# Lender-funded RealFi pools: local mainnet fork

A Hardhat fork of Ethereum (chain id 1) from the local archive node, with Fabio's RealFiStructures builds and six
EulerSwap pools that buy USDrf and sUSDrf with loans from our Euler vaults.

| Port | What |
|---|---|
| 8547 | The Hardhat fork (`fork-node.sh`, launchd label `com.root.realfi-fork`) |
| 8548 | The same fork for cast and forge (`rpc-shim.py`, label `com.root.realfi-shim`): Hardhat 2 refuses Foundry's calls otherwise |

Built in this order (each script refuses anything but the fork):

1. Fabio's builds 1 to 3: `yarn workspace @realfi-structures/deploy deploy --env mainnet-fork --config <this folder>/fabio-fork.json --confirm-chain 1 --impersonate-deployer 0x501107fe590c8F9b81c00b81867fD19e0d9c0253`. The config copy names the Safe as profit receiver and allows eUSDrf-2's live 15% liquidation bonus. Book: `RealFiStructures/deploy/deployments/mainnet-fork/addresses.json`.
2. `realfi-list.sh`: RealFi's listings, as its list admin.
3. `safe-batch.sh`: the pending RWA Safe batch, as the Safe.
4. `load.sh`: lenders put 4.5M USDC in eUSDC-143, 3M USDC in eUSDC-69 and 1.5M USDrf in each USDrf vault; each pool account gets a 100k collateral cushion.
5. `script/Pools.s.sol`: the six pools, sub-accounts 1 to 6 of `0x000000000000000000000000000000000000Aa00`.
6. `split-swap.sh <RealFi> <RWA>`: one Uniswap router call sells USDrf through both clusters' USDrf pools.

| Pool | Address | Pays with a loan from |
|---|---|---|
| RealFi USDrf to USDC | 0x7C4ecF5D9c35d70FD17Ee06D92b1320BF02Be8A8 | eUSDC-143 |
| RealFi sUSDrf to USDC | 0xd85549e59dd52bB35244bC36BA3fE356C01E68a8 | eUSDC-143 |
| RealFi sUSDrf to USDrf | 0x0e3a1710bF96F7638943e78178d28EBC64Ea68A8 | eUSDrf-2 |
| RWA USDrf to USDC | 0x5408978792D4524f48afA1f163dF9D40C06668a8 | eUSDC-69 |
| RWA sUSDrf to USDC | 0x13b6B0f48f75D95853410749eefB81D7cfBa28a8 | eUSDC-69 |
| RWA sUSDrf to USDrf | 0x1EC6CFA06AA1C4350749a5251F4e4102A54D68a8 | eUSDrf-1 |

Every pool: a flat price (USDrf at $1, sUSDrf at RealFi's rate when deployed) and a 0.30% fee, set in `Pools.s.sol`.

A fork restart loses everything: run steps 1 to 5 again.
