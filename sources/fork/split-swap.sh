#!/bin/zsh
# Fork only: one Uniswap UniversalRouter call sells USDrf for USDC through two EulerSwap pools at once, the RealFi
# cluster's and the RWA cluster's. Uniswap v4 settles both legs once at the end of the call.
#   zsh split-swap.sh <USDrf into the RealFi pool> <USDrf into the RWA pool>     (whole tokens)
set -u
F=http://127.0.0.1:8548
[ "$(cast rpc hardhat_metadata -r $F 2>/dev/null | grep -c forkedNetwork)" = 1 ] || { print -u2 "refusing: not the Hardhat fork"; exit 1; }
T=0x000000000000000000000000000000000000C0DE   # the trader, listed with RealFi on the fork
USDC=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; USDRF=0xD75647217206052F6090678905026AA374431563
UR=0x66a9893cC07D91D95644AEDD05D03f95e1dBA8Af; PERMIT2=0x000000000022D473030F116dDEE9F6B43aC78BA3
RF_POOL=0x7C4ecF5D9c35d70FD17Ee06D92b1320BF02Be8A8; RWA_POOL=0x5408978792D4524f48afA1f163dF9D40C06668a8
A1=$(( $1 * 1000000 )); A2=$(( $2 * 1000000 )); TOTAL=$(( A1 + A2 ))
cast rpc hardhat_impersonateAccount $T -r $F >/dev/null; cast rpc hardhat_setBalance $T 0x8AC7230489E80000 -r $F >/dev/null
slot=$(cast index address $T 0x52c63247e1f47db19d5ce0460030c497f067ca4cebf71ba98eeadabe20bace00)
cast rpc hardhat_setStorageAt $USDRF $slot $(cast to-uint256 $TOTAL) -r $F >/dev/null
u() { cast send "$@" -r $F --from $T --unlocked --gas-limit 3000000 --json 2>/dev/null | python3 -c 'import json,sys
try: print("OK" if json.load(sys.stdin)["status"]=="0x1" else "REVERTED")
except Exception: print("REVERTED")'; }
u $USDRF 'approve(address,uint256)' $PERMIT2 $(cast max-uint) >/dev/null
u $PERMIT2 'approve(address,address,uint160,uint48)' $USDRF $UR $TOTAL 4102444800 >/dev/null
leg() { cast abi-encode 'f(((address,address,uint24,int24,address),bool,uint128,uint128,bytes))' "(($USDC,$USDRF,0,1,$1),false,$2,0,0x)"; }
# Pay the USDrf in first: EulerSwap's hook takes its input from the PoolManager inside the swap, and the PoolManager
# holds no USDrf of its own, so the usual swap-then-settle order reverts (ERC20InsufficientBalance on the PoolManager).
actions=0x0b06060f   # settle USDrf from the trader, swap exact in (RealFi pool), swap exact in (RWA pool), take all USDC
params="[$(cast abi-encode 'f(address,uint256,bool)' $USDRF $TOTAL true),$(leg $RF_POOL $A1),$(leg $RWA_POOL $A2),$(cast abi-encode 'f(address,uint256)' $USDC 0)]"
input=$(cast abi-encode 'f(bytes,bytes[])' $actions "$params")
before=$(cast call $USDC 'balanceOf(address)(uint256)' $T -r $F | awk '{print $1}')
debt() { cast call $1 'debtOf(address)(uint256)' $2 -r $F | awk '{printf "%.0f", $1/1e6}'; }
print "selling $1 USDrf to the RealFi pool and $2 USDrf to the RWA pool, in one router call"
print "  router: $(u $UR 'execute(bytes,bytes[],uint256)' 0x10 "[$input]" 4102444800)"
after=$(cast call $USDC 'balanceOf(address)(uint256)' $T -r $F | awk '{print $1}')
print "  trader received $(python3 -c "print(f'{($after-$before)/1e6:,.2f}')") USDC for $(python3 -c "print(f'{$TOTAL/1e6:,.0f}')") USDrf"
print "  RealFi pool now owes $(debt 0x3c089C265A86eCFB9BA6D5a3EFBE27eABa29E6c4 0x000000000000000000000000000000000000Aa01) USDC to eUSDC-143"
print "  RWA pool now owes $(debt 0x2a356443FeE07703266066c6Bb1B11b82d8246AD 0x000000000000000000000000000000000000Aa04) USDC to eUSDC-69"
