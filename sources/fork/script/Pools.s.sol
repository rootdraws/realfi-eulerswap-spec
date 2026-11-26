// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";

// Fork only. Six lender-funded EulerSwap v2 pools on Ethereum, three in the RealFi cluster and the same three in the RWA
// cluster. Each pool buys a RealFi token and pays with a loan from that cluster's vault:
//   USDrf in, USDC out    (USDrf collateral, USDC loan)
//   sUSDrf in, USDC out   (sUSDrf collateral, USDC loan)
//   sUSDrf in, USDrf out  (sUSDrf collateral, USDrf loan)
// Each pool trades from its own EVC sub-account of OWNER (one account may owe one vault at a time). Flat price, 0.30% fee.
// Run: forge script script/Pools.s.sol --rpc-url http://127.0.0.1:8548 --unlocked --sender <OWNER> --broadcast

interface IEVC {
    function setAccountOperator(address account, address operator, bool authorized) external payable;
    function call(address target, address onBehalfOf, uint256 value, bytes calldata data) external payable returns (bytes memory);
}

interface IFactory {
    struct StaticParams { address supplyVault0; address supplyVault1; address borrowVault0; address borrowVault1; address eulerAccount; address feeRecipient; }
    struct DynamicParams {
        uint112 equilibriumReserve0; uint112 equilibriumReserve1; uint112 minReserve0; uint112 minReserve1;
        uint80 priceX; uint80 priceY; uint64 concentrationX; uint64 concentrationY; uint64 fee0; uint64 fee1;
        uint40 expiration; uint8 swapHookedOperations; address swapHook;
    }
    struct InitialState { uint112 reserve0; uint112 reserve1; }
    function deployPool(StaticParams memory, DynamicParams memory, InitialState memory, bytes32) external returns (address);
    function creationCode(StaticParams memory) external view returns (bytes memory);
}

interface IVault { function convertToAssets(uint256) external view returns (uint256); }

contract Pools is Script {
    IEVC constant EVC = IEVC(0x0C9a3dd6b8F28529d72d7f9cE918D493519EE383);
    IFactory constant FACTORY = IFactory(0xD05213331221fAB8a3C387F2affBb605Bb04DF5F);
    address constant SUSDRF = 0x8f4507d315acf966Fe21F9f4feE4F7e1A6d4c400;
    // RealFi cluster
    address constant RF_USDC = 0x3c089C265A86eCFB9BA6D5a3EFBE27eABa29E6c4;   // eUSDC-143
    address constant RF_USDRF = 0xEf240d6f1f2373bE393153F3125a3B514b204775;  // eUSDrf-2
    address constant RF_SUSDRF = 0x0e10056d88084D76A7df6CC612330aF1B60B0130; // esUSDrf-2
    // RWA cluster
    address constant RWA_USDC = 0x2a356443FeE07703266066c6Bb1B11b82d8246AD;  // eUSDC-69
    address constant RWA_USDRF = 0x0F4E2AF3042FdECC3A10707252e8d617DB3B35c3; // eUSDrf-1
    address constant RWA_SUSDRF = 0x0Ee3807A399BFC5F58ed88faEf1a4A40F0EA0601; // esUSDrf-1

    uint160 constant FLAGS = (1 << 13) | (1 << 11) | (1 << 7) | (1 << 5) | (1 << 3); // EulerSwap's v4 hook permissions
    uint160 constant MASK = (1 << 14) - 1;
    uint64 constant FEE = 0.003e18;
    uint112 constant USDC_ROOM = 5_000_000e6;   // the most USDC a pool may pay out; the loan limit binds first
    uint112 constant USDRF_ROOM = 2_000_000e6;

    function run() external {
        address owner = msg.sender;
        uint256 rate = IVault(SUSDRF).convertToAssets(1e6); // USDrf per sUSDrf, 6 decimals each
        uint80 susdrfPx = uint80(rate * 1e12);
        vm.startBroadcast();
        // token order: sUSDrf 0x8f45 < USDC 0xA0b8 < USDrf 0xD756
        deploy("RealFi USDrf->USDC", sub(owner, 1), RF_USDC, RF_USDRF, RF_USDC, address(0), USDC_ROOM, 0, 1e18, 1e18);
        deploy("RealFi sUSDrf->USDC", sub(owner, 2), RF_SUSDRF, RF_USDC, address(0), RF_USDC, 0, USDC_ROOM, susdrfPx, 1e18);
        deploy("RealFi sUSDrf->USDrf", sub(owner, 3), RF_SUSDRF, RF_USDRF, address(0), RF_USDRF, 0, USDRF_ROOM, susdrfPx, 1e18);
        deploy("RWA USDrf->USDC", sub(owner, 4), RWA_USDC, RWA_USDRF, RWA_USDC, address(0), USDC_ROOM, 0, 1e18, 1e18);
        deploy("RWA sUSDrf->USDC", sub(owner, 5), RWA_SUSDRF, RWA_USDC, address(0), RWA_USDC, 0, USDC_ROOM, susdrfPx, 1e18);
        deploy("RWA sUSDrf->USDrf", sub(owner, 6), RWA_SUSDRF, RWA_USDRF, address(0), RWA_USDRF, 0, USDRF_ROOM, susdrfPx, 1e18);
        vm.stopBroadcast();
    }

    function sub(address owner, uint8 i) internal pure returns (address) {
        return address(uint160(owner) ^ uint160(i));
    }

    function deploy(string memory name, address account, address v0, address v1, address b0, address b1, uint112 r0,
        uint112 r1, uint80 px, uint80 py) internal {
        IFactory.StaticParams memory sp = IFactory.StaticParams(v0, v1, b0, b1, account, address(0));
        IFactory.DynamicParams memory dp =
            IFactory.DynamicParams(r0, r1, 0, 0, px, py, 1e18, 1e18, FEE, FEE, 0, 0, address(0));
        bytes32 h = keccak256(FACTORY.creationCode(sp));
        address pool; uint256 salt;
        for (;; salt++) {
            pool = address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(FACTORY), bytes32(salt), h)))));
            if (uint160(pool) & MASK == FLAGS && pool.code.length == 0) break;
        }
        EVC.setAccountOperator(account, pool, true);
        bytes memory out = EVC.call(address(FACTORY), account, 0,
            abi.encodeCall(IFactory.deployPool, (sp, dp, IFactory.InitialState(r0, r1), bytes32(salt))));
        require(abi.decode(out, (address)) == pool, "pool address");
        console2.log(name, pool, account);
    }
}
