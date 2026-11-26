#!/bin/zsh
# Fork only: does RealFi's part by impersonating the admin of its three lists.
#   zsh realfi-list.sh allow:<addr> liq:<addr> list:<addr> exempt:<addr> ...
#   allow  = AllowlistRegistry (may mint and redeem), liq = StakeDesk liquidator (instant unstake),
#   list   = EvmAccessList listed, exempt = EvmAccessList exempt
set -u
F=http://127.0.0.1:8548
[ "$(cast rpc hardhat_metadata -r $F 2>/dev/null | grep -c forkedNetwork)" = 1 ] || { print -u2 "refusing: not the Hardhat fork"; exit 1; }
ADMIN=0x7ee6e885704fdd1e0e6a619a6806b47882e308a0
ALLOW=0x763267fa41Fc4a1aE5E6DC0da410815fBcA96b53; DESK=0x0CDf9283D79E7fFd421F8065f207dFeA6C41dA3b; ACCESS=0xE7Ab45F75cfDf8E6B0161957759a5faC87b7ACB0
cast rpc hardhat_impersonateAccount $ADMIN -r $F >/dev/null; cast rpc hardhat_setBalance $ADMIN 0x8AC7230489E80000 -r $F >/dev/null
tx() { cast send "$@" --from $ADMIN --unlocked -r $F --gas-limit 1000000 --json 2>&1 | python3 -c 'import json,sys
try: print("OK" if json.load(sys.stdin)["status"]=="0x1" else "REVERTED")
except Exception: print("REVERTED")'; }
role() { local c=$1 r=$(cast keccak $2)
  [ "$(cast call $c 'hasRole(bytes32,address)(bool)' $r $ADMIN -r $F)" = true ] || print "  grant $2: $(tx $c 'grantRole(bytes32,address)' $r $ADMIN)"; }
role $ALLOW MANAGER_ROLE; role $DESK LIQUIDATOR_MANAGER_ROLE; role $ACCESS ACCESS_MANAGER_ROLE
for a in "$@"; do
  k=${a%%:*} v=${a#*:}
  case $k in
    allow)  print "  allow $v: $(tx $ALLOW 'allow(address)' $v)" ;;
    liq)    print "  liquidator $v: $(tx $DESK 'addLiquidator(address)' $v)" ;;
    list)   print "  list $v: $(tx $ACCESS 'list(address)' $v)" ;;
    exempt) print "  exempt $v: $(tx $ACCESS 'setExempt(address,bool)' $v true)" ;;
  esac
done
