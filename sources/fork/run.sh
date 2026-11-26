#!/bin/zsh
# Runs the whole mainnet fork test against a fresh fork: deploys Builds 1 to 3, does RealFi's listings, fills the lending
# vaults, deploys the four EulerSwap pools, and trades through them. Needs fork-node.sh and rpc-shim.py running.
#   REALFI_STRUCTURES=<path to the RealFiStructures checkout> zsh run.sh
set -eu
: ${REALFI_STRUCTURES:?set REALFI_STRUCTURES to your RealFiStructures checkout}
HERE=${0:A:h}
F=http://127.0.0.1:8548
[ "$(cast rpc hardhat_metadata -r $F 2>/dev/null | grep -c forkedNetwork)" = 1 ] || { print -u2 "start fork-node.sh and rpc-shim.py first"; exit 1; }
command -v yarn >/dev/null || { print -u2 "put Node 22 and yarn on PATH (nvm use in the RealFiStructures checkout)"; exit 1; }
[ -f $REALFI_STRUCTURES/env/.env.mainnet-fork ] || { print -u2 "create env/.env.mainnet-fork first (see README)"; exit 1; }
DEPLOYER=0x501107fe590c8F9b81c00b81867fD19e0d9c0253; OWNER=0x000000000000000000000000000000000000Aa00
USDC=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
BOOK=$REALFI_STRUCTURES/deploy/deployments/mainnet-fork/addresses.json

print "1. Builds 1 to 3"
cast rpc hardhat_setBalance $DEPLOYER 0x56BC75E2D63100000 -r $F >/dev/null
cast rpc hardhat_setStorageAt $USDC $(cast index address $DEPLOYER 9) $(cast to-uint256 1000000000) -r $F >/dev/null
rm -f $BOOK
deploy() { (cd $REALFI_STRUCTURES && yarn -s workspace @realfi-structures/deploy deploy --env mainnet-fork \
  --config $HERE/realfi-fork-config.json --confirm-chain 1 --impersonate-deployer $DEPLOYER > $HERE/deploy.log 2>&1) || true; }
deploy
print "2. RealFi's listings, as RealFi's list admin"
n=$(zsh $HERE/realfi-list.sh $(python3 - $BOOK <<'PY'
import json, sys
b = json.load(open(sys.argv[1])); b1, b2, b3, x = b['build1'], b['build2'], b['build3'], b['external']
rows = [('allow', b1['realfiAdapter']), ('liq', b1['realfiAdapter']), ('list', b1['realfiAdapter']),
        ('list', b1['controller']), ('list', b1['unstakeEscrow']), ('list', b1['eulerMarketAdapter']),
        ('allow', b2['hook']), ('list', b2['hook']), ('list', b2['treasury']), ('list', x['poolManager']),
        ('list', x['universalRouter']), ('list', b2['pool2Hook']), ('list', b2['pool2Treasury']),
        ('liq', b3['liquidator']), ('list', b3['liquidator']), ('list', b['roles']['profitReceiver'])]
print(' '.join(f'{k}:{a}' for k, a in rows))
PY
) | grep -c OK); print "   $n listings done"
deploy
grep -q "^done  listings.b3" $HERE/deploy.log && print "   deploy finished" || { print -u2 "deploy did not finish: see deploy.log"; exit 1; }

print "3. Lenders and pool stock"
n=$(zsh $HERE/load.sh | grep -c OK); print "   $n deposits done"

print "4. The four EulerSwap pools"
(cd $HERE && forge script script/Pools.s.sol --rpc-url $F --unlocked --sender $OWNER --broadcast --slow > pools.log 2>&1)
pools=($(grep -oE '0x[0-9a-fA-F]{40} 0x0{36}' $HERE/pools.log | awk '{print $1}'))
print "   ${#pools} pools deployed"
n=$(zsh $HERE/realfi-list.sh list:0x000000000000000000000000000000000000C0DE ${pools/#/list:} | grep -c OK); print "   $n listings done"

print "5. Trades"
zsh $HERE/split-swap.sh sell 400000 400000 ${pools[1]} ${pools[3]}
zsh $HERE/split-swap.sh buy 200000 200000 ${pools[1]} ${pools[3]}
