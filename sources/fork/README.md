# Lender-funded RealFi pools: local mainnet fork

A Hardhat fork of Ethereum (chain id 1) from the local archive node, with Fabio's RealFiStructures builds and four
EulerSwap pools that trade sUSDrf both ways against loans from our Euler vaults.

| Port | What |
|---|---|
| 8547 | The Hardhat fork (`fork-node.sh`, launchd label `com.root.realfi-fork`) |
| 8548 | The same fork for cast and forge (`rpc-shim.py`, label `com.root.realfi-shim`): Hardhat 2 refuses Foundry's calls otherwise |

Built in this order (each script refuses anything but the fork):

1. Fabio's builds 1 to 3: `yarn workspace @realfi-structures/deploy deploy --env mainnet-fork --config <this folder>/fabio-fork.json --confirm-chain 1 --impersonate-deployer 0x501107fe590c8F9b81c00b81867fD19e0d9c0253`. The config copy names the Safe as profit receiver and allows eUSDrf-2's live 15% liquidation bonus. Book: `RealFiStructures/deploy/deployments/mainnet-fork/addresses.json`.
2. `realfi-list.sh`: RealFi's listings, as its list admin.
3. `safe-batch.sh`: the pending RWA Safe batch, as the Safe.
4. `load.sh`: lenders put 4.5M USDC in eUSDC-143, 3M USDC in eUSDC-69 and 1.5M USDrf in each USDrf vault; each pool account gets 100k sUSDrf.
5. `script/Pools.s.sol`: the four pools, sub-accounts 7 to 10 of `0x000000000000000000000000000000000000Aa00`.
6. `split-swap.sh sell|buy <RealFi> <RWA>`: one Uniswap router call trades sUSDrf against USDC through both clusters' pools.

| Pool | Address | Borrows from |
|---|---|---|
| RealFi sUSDrf <> USDC | 0xBdAa1a39cF93f9dC0Ed324748494c21f6986E8A8 | eUSDC-143 |
| RealFi sUSDrf <> USDrf | 0xe39EA50e9243ac2b9AFC9E6318791466B7A128A8 | eUSDrf-2 |
| RWA sUSDrf <> USDC | 0xaE77E5B69Ef6BffaD81f9c1AE92E560Eb0D928a8 | eUSDC-69 |
| RWA sUSDrf <> USDrf | 0x2E01bE201f33B7E70Ff6ba2C29d7641Cf6f768a8 | eUSDrf-1 |

Every pool: a flat price (sUSDrf at RealFi's rate when deployed) and a 0.30% fee, set in `Pools.s.sol`.

A fork restart loses everything: run steps 1 to 5 again.
