#!/bin/zsh
# Fork only: one Uniswap UniversalRouter call trades sUSDrf against USDC through both clusters' sUSDrf<>USDC EulerSwap
# pools at once. Uniswap v4 settles both legs once at the end of the call.
#   zsh split-swap.sh sell <sUSDrf into RealFi> <sUSDrf into RWA>    sells sUSDrf; each pool borrows USDC to pay
#   zsh split-swap.sh buy  <USDC into RealFi> <USDC into RWA>        buys sUSDrf; the USDC repays each pool's loan
set -u
F=http://127.0.0.1:8548
[ "$(cast rpc hardhat_metadata -r $F 2>/dev/null | grep -c forkedNetwork)" = 1 ] || { print -u2 "refusing: not the Hardhat fork"; exit 1; }
T=0x000000000000000000000000000000000000C0DE   # the trader, listed with RealFi on the fork
USDC=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; SUSDRF=0x8f4507d315acf966Fe21F9f4feE4F7e1A6d4c400
UR=0x66a9893cC07D91D95644AEDD05D03f95e1dBA8Af; PERMIT2=0x000000000022D473030F116dDEE9F6B43aC78BA3
RF_POOL=0xBdAa1a39cF93f9dC0Ed324748494c21f6986E8A8; RWA_POOL=0xaE77E5B69Ef6BffaD81f9c1AE92E560Eb0D928a8
RF_ACCT=0x000000000000000000000000000000000000Aa07; RWA_ACCT=0x000000000000000000000000000000000000aA09
MODE=$1; A1=$(( $2 * 1000000 )); A2=$(( $3 * 1000000 )); TOTAL=$(( A1 + A2 ))
if [ $MODE = sell ]; then IN=$SUSDRF; OUT=$USDC; Z=true; else IN=$USDC; OUT=$SUSDRF; Z=false; fi
cast rpc hardhat_impersonateAccount $T -r $F >/dev/null; cast rpc hardhat_setBalance $T 0x8AC7230489E80000 -r $F >/dev/null
if [ $IN = $USDC ]; then slot=$(cast index address $T 9); else slot=$(cast index address $T 0x52c63247e1f47db19d5ce0460030c497f067ca4cebf71ba98eeadabe20bace00); fi
cast rpc hardhat_setStorageAt $IN $slot $(cast to-uint256 $TOTAL) -r $F >/dev/null
u() { cast send "$@" -r $F --from $T --unlocked --gas-limit 3000000 --json 2>/dev/null | python3 -c 'import json,sys
try: print("OK" if json.load(sys.stdin)["status"]=="0x1" else "REVERTED")
except Exception: print("REVERTED")'; }
u $IN 'approve(address,uint256)' $PERMIT2 $(cast max-uint) >/dev/null
u $PERMIT2 'approve(address,address,uint160,uint48)' $IN $UR $TOTAL 4102444800 >/dev/null
leg() { cast abi-encode 'f(((address,address,uint24,int24,address),bool,uint128,uint128,bytes))' "(($SUSDRF,$USDC,0,1,$1),$Z,$2,0,0x)"; }
# EulerSwap's hook takes its input from the PoolManager inside the swap, so the input is settled first.
actions=0x0b06060f   # settle the input, swap exact in (RealFi pool), swap exact in (RWA pool), take all of the output
params="[$(cast abi-encode 'f(address,uint256,bool)' $IN $TOTAL true),$(leg $RF_POOL $A1),$(leg $RWA_POOL $A2),$(cast abi-encode 'f(address,uint256)' $OUT 0)]"
input=$(cast abi-encode 'f(bytes,bytes[])' $actions "$params")
bal() { cast call $1 'balanceOf(address)(uint256)' $T -r $F | awk '{print $1}'; }
debt() { cast call $1 'debtOf(address)(uint256)' $2 -r $F | awk '{printf "%.0f", $1/1e6}'; }
before=$(bal $OUT)
print "$MODE: $2 into the RealFi pool and $3 into the RWA pool, in one router call"
print "  router: $(u $UR 'execute(bytes,bytes[],uint256)' 0x10 "[$input]" 4102444800)"
print "  trader received $(python3 -c "print(f'{($(bal $OUT)-$before)/1e6:,.2f}')") $([ $OUT = $USDC ] && print USDC || print sUSDrf)"
print "  RealFi pool owes $(debt 0x3c089C265A86eCFB9BA6D5a3EFBE27eABa29E6c4 $RF_ACCT) USDC to eUSDC-143; RWA pool owes $(debt 0x2a356443FeE07703266066c6Bb1B11b82d8246AD $RWA_ACCT) USDC to eUSDC-69"
