#!/bin/zsh
# Starts a Hardhat node on chain id 1 that forks Ethereum mainnet at its latest block, on port 8547.
# The RealFiStructures deploy engine needs a Hardhat fork, not anvil.
#   ARCHIVE_RPC=<archive rpc url> REALFI_STRUCTURES=<path to the RealFiStructures checkout> zsh fork-node.sh
set -eu
: ${ARCHIVE_RPC:?set ARCHIVE_RPC to an Ethereum archive RPC}
: ${REALFI_STRUCTURES:?set REALFI_STRUCTURES to your RealFiStructures checkout}
cd $REALFI_STRUCTURES/contracts
HARDHAT_CHAIN_ID=1 exec npx hardhat node --fork $ARCHIVE_RPC --port 8547 --hostname 127.0.0.1
