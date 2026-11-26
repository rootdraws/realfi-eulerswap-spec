#!/bin/zsh
# Fork only: executes the pending RWA Safe batch (ag-euler/safe-payloads/ethereum-realfi-rwa.json) as the AlphaGrowth Safe.
set -u
F=http://127.0.0.1:8548
[ "$(cast rpc hardhat_metadata -r $F 2>/dev/null | grep -c forkedNetwork)" = 1 ] || { print -u2 "refusing: not the Hardhat fork"; exit 1; }
SAFE=0x4f894Bfc9481110278C356adE1473eBe2127Fd3C
cast rpc hardhat_impersonateAccount $SAFE -r $F >/dev/null; cast rpc hardhat_setBalance $SAFE 0x8AC7230489E80000 -r $F >/dev/null
python3 -c "
import json, os
for t in json.load(open(os.path.expanduser('~/ag-euler/safe-payloads/ethereum-realfi-rwa.json')))['transactions']:
    ins=t['contractMethod']['inputs']; sig=t['contractMethod']['name']+'('+','.join(i['type'] for i in ins)+')'
    print(t['to'], sig, *[t['contractInputsValues'][i['name']] for i in ins])" | while read -r to sig args; do
  print "  Safe -> ${to:0:10} $sig: $(cast send $to "$sig" ${=args} --from $SAFE --unlocked --gas-limit 2000000 -r $F --json | python3 -c 'import json,sys; print("OK" if json.load(sys.stdin)["status"]=="0x1" else "REVERTED")')"
done
