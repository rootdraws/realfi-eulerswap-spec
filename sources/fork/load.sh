#!/bin/zsh
# Fork only: fills the lending vaults and each pool's collateral cushion. Tokens are written into balances directly.
#   LENDER deposits USDC and USDrf for the pools to borrow; OWNER parks a 100k cushion in each pool's sub-account.
set -u
F=http://127.0.0.1:8548
[ "$(cast rpc hardhat_metadata -r $F 2>/dev/null | grep -c forkedNetwork)" = 1 ] || { print -u2 "refusing: not the Hardhat fork"; exit 1; }
LENDER=0x000000000000000000000000000000000000BEEF; OWNER=0x000000000000000000000000000000000000Aa00
USDC=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; USDRF=0xD75647217206052F6090678905026AA374431563; SUSDRF=0x8f4507d315acf966Fe21F9f4feE4F7e1A6d4c400
RF_USDC=0x3c089C265A86eCFB9BA6D5a3EFBE27eABa29E6c4; RF_USDRF=0xEf240d6f1f2373bE393153F3125a3B514b204775; RF_SUSDRF=0x0e10056d88084D76A7df6CC612330aF1B60B0130
RWA_USDC=0x2a356443FeE07703266066c6Bb1B11b82d8246AD; RWA_USDRF=0x0F4E2AF3042FdECC3A10707252e8d617DB3B35c3; RWA_SUSDRF=0x0Ee3807A399BFC5F58ed88faEf1a4A40F0EA0601
for a in $LENDER $OWNER; do cast rpc hardhat_impersonateAccount $a -r $F >/dev/null; cast rpc hardhat_setBalance $a 0x8AC7230489E80000 -r $F >/dev/null; done
u() { cast send "$@" -r $F --unlocked --gas-limit 3000000 --json 2>/dev/null | python3 -c 'import json,sys
try: print("OK" if json.load(sys.stdin)["status"]=="0x1" else "REVERTED")
except Exception: print("REVERTED")'; }
put() { # put <token> <wallet> <whole tokens>: writes the balance (USDC slot 9; RealFi tokens use OpenZeppelin v5's ERC20 slot)
  local slot amt=$(( $3 * 1000000 ))
  if [ $1 = $USDC ]; then slot=$(cast index address $2 9); else slot=$(cast index address $2 0x52c63247e1f47db19d5ce0460030c497f067ca4cebf71ba98eeadabe20bace00); fi
  cast rpc hardhat_setStorageAt $1 $slot $(cast to-uint256 $(( $(cast to-dec $(cast storage $1 $slot -r $F)) + amt ))) -r $F >/dev/null; }
dep() { # dep <from> <vault> <token> <whole tokens> <receiver>
  put $3 $1 $4; u $3 'approve(address,uint256)' $2 $(cast max-uint) --from $1 >/dev/null
  print "  ${5:0:12} gets $4 in $(cast call $2 'symbol()(string)' -r $F): $(u $2 'deposit(uint256,address)' $(( $4 * 1000000 )) $5 --from $1)"; }
sub() { python3 -c "print('0x%040x' % (int('$OWNER',16) ^ $1))"; }
print "lenders"
dep $LENDER $RF_USDC $USDC 4500000 $LENDER
dep $LENDER $RF_USDRF $USDRF 1500000 $LENDER
dep $LENDER $RWA_USDC $USDC 3000000 $LENDER
dep $LENDER $RWA_USDRF $USDRF 1500000 $LENDER
print "pool cushions"
dep $OWNER $RF_USDRF $USDRF 100000 $(sub 1)
dep $OWNER $RF_SUSDRF $SUSDRF 100000 $(sub 3)
dep $OWNER $RWA_USDRF $USDRF 100000 $(sub 4)
dep $OWNER $RWA_SUSDRF $SUSDRF 100000 $(sub 6)
