# Mainnet fork test

These scripts deploy everything on a local fork of Ethereum mainnet and trade through it. Every script refuses to run
against anything but the fork.

## What you need

- An Ethereum archive RPC.
- Node 22 and yarn, Foundry, Python 3 and zsh.
- A checkout of [alphagrowth/RealFiStructures](https://github.com/alphagrowth/RealFiStructures) (private, access on
  request), set up with `nvm use && yarn setup`.

## Setup

1. In the RealFiStructures checkout, copy `env/.env.mainnet-fork.example` to `env/.env.mainnet-fork`. Set `RPC_URL` to
   `http://127.0.0.1:8547`, and fill the three role keys with three different Hardhat test keys. They sign only on the fork.
2. In this folder, run `forge install foundry-rs/forge-std --no-git`.

## Run

Start the fork and the RPC shim, each in its own terminal:

```sh
ARCHIVE_RPC=<archive rpc> REALFI_STRUCTURES=<path to RealFiStructures> zsh fork-node.sh   # Hardhat fork on port 8547
python3 rpc-shim.py   # port 8548; Hardhat 2 rejects Foundry's calls without it
```

Then run the test, with Node 22 and yarn on your PATH:

```sh
REALFI_STRUCTURES=<path to RealFiStructures> zsh run.sh
```

`run.sh` does five things:

1. It deploys Builds 1 to 3 with the RealFiStructures deploy engine, signing as AlphaGrowth's deployer through the fork.
2. It adds RealFi's listings by signing as RealFi's list admin.
3. It deposits 7.5M USDC and 3M USDrf as lenders, and gives each pool 100k sUSDrf.
4. It deploys the four EulerSwap pools.
5. It sells 800k sUSDrf through two pools in one transaction, then buys some back.

Each step can also run on its own: `realfi-list.sh`, `load.sh`, `script/Pools.s.sol` and `split-swap.sh`.

## Launching the pools on mainnet

`script/Pools.s.sol` is a test deployment: its pools use a fixed price set at deploy. A mainnet launch needs the swap
hook that tracks RealFi's rate ([08](../../08-eulerswap-pools.md)), a chosen owner and fee, and RealFi's listing of each
pool.
