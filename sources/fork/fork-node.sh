#!/bin/zsh
# A Hardhat node on chain id 1 that forks Ethereum from the local archive node at its latest block, on port 8547 so it
# never collides with the archive node's 8545. Fabio's deploy engine (RealFiStructures, env mainnet-fork) needs Hardhat.
# Start it with: ~/launchd-run.sh realfi-fork ~/ag-euler/contracts/realfi-eulerswap fork-node.sh
source $HOME/.nvm/nvm.sh
cd $HOME/ag-structures/RealFiStructures && nvm use >/dev/null
cd contracts
print "$(date -u +%FT%TZ) starting the fork of $(cast block-number -r http://127.0.0.1:8545)"
HARDHAT_CHAIN_ID=1 exec npx hardhat node --fork http://127.0.0.1:8545 --port 8547 --hostname 127.0.0.1
