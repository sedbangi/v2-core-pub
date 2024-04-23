// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

import { Test } from "forge-std/Test.sol";
import { ISystemRegistry } from "src/interfaces/ISystemRegistry.sol";
import { IRootPriceOracle } from "src/interfaces/oracles/IRootPriceOracle.sol";
import { ISpotPriceOracle } from "src/interfaces/oracles/ISpotPriceOracle.sol";
import { IVault as IBalancerVault } from "src/interfaces/external/balancer/IVault.sol";
import { BalancerGyroscopeEthOracle } from "src/oracles/providers/BalancerGyroscopeEthOracle.sol";
import { BAL_VAULT, WETH_MAINNET, WSTETH_MAINNET, CBETH_MAINNET, WSTETH_WETH_GYRO_POOL } from "test/utils/Addresses.sol";

// solhint-disable func-name-mixedcase

contract BalancerGyroscopeEthOracleTests is Test {
    IBalancerVault internal constant VAULT = IBalancerVault(BAL_VAULT);
    // address private constant WSTETH = address(WSTETH_MAINNET);
    // address private constant CBETH = address(CBETH_MAINNET);
    // address private constant WSTETH_CBETH_POOL = address(CBETH_WSTETH_BAL_POOL);

    IRootPriceOracle internal rootPriceOracle;
    ISystemRegistry internal systemRegistry;
    BalancerGyroscopeEthOracle internal oracle;

    event ReceivedPrice();

    function setUp() public {
        uint256 mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"), 19_661_436);
        vm.selectFork(mainnetFork);

        rootPriceOracle = IRootPriceOracle(vm.addr(324));
        systemRegistry = generateSystemRegistry(address(rootPriceOracle));
        oracle = new BalancerGyroscopeEthOracle(systemRegistry, VAULT);
    }

    function testConstruction() public {
        assertEq(address(systemRegistry), address(oracle.getSystemRegistry()));
        assertEq(address(VAULT), address(oracle.balancerVault()));
    }

    function generateSystemRegistry(address rootOracle) internal returns (ISystemRegistry) {
        address registry = vm.addr(327_849);
        vm.mockCall(registry, abi.encodeWithSelector(ISystemRegistry.rootPriceOracle.selector), abi.encode(rootOracle));
        return ISystemRegistry(registry);
    }
}

contract GetSpotPrice is BalancerGyroscopeEthOracleTests {
    /// @dev rEth -> sfrxETH at block 17_378_951 is 1.029499830936747431.
    /// Pool has no WETH so it returns sfrxETH
    function skip_test_getSpotPrice_withWETHQuote() public {
        // (uint256 price, address quoteToken) =
        //     oracle.getSpotPrice(RETH_MAINNET, WSETH_RETH_SFRXETH_BAL_POOL, WETH_MAINNET);

        // assertEq(quoteToken, SFRXETH_MAINNET);
        // assertEq(price, 1_029_499_830_936_747_431);
    }

    /// @dev rEth -> wstETH at block 17_378_951 is 0.952518727388269243.
    function skip_test_getSpotPrice_withoutWETHQuote() public {
        // (uint256 price, address quoteToken) = oracle.getSpotPrice(
        //     RETH_MAINNET, // rEth
        //     WSETH_RETH_SFRXETH_BAL_POOL,
        //     WSTETH_MAINNET // wstETH
        // );

        // assertEq(quoteToken, WSTETH_MAINNET);
        // assertEq(price, 952_518_727_388_269_243);
    }
}

contract GetSafeSpotPriceInfo is BalancerGyroscopeEthOracleTests {
    function test_getSafeSpotPriceInfo() public {
        deal(address(WSTETH_MAINNET), address(this), 20 * 1e18);
        deal(address(WETH_MAINNET), address(this), 20 * 1e18);
        deal(address(this), 3 ether);

        (uint256 totalLPSupply, ISpotPriceOracle.ReserveItemInfo[] memory reserves) =
            oracle.getSafeSpotPriceInfo(WSTETH_WETH_GYRO_POOL, WSTETH_WETH_GYRO_POOL, WETH_MAINNET);

        assertEq(reserves.length, 2, "rlen");
        assertEq(totalLPSupply, 1_897_851_032_140_955_202_888, "totalLPSupply");
        assertEq(reserves[0].token, WSTETH_MAINNET, "token0");
        assertEq(reserves[0].reserveAmount, 1_652_533_650_840_616_473_656, "reserveAmount0");
        assertEq(reserves[0].rawSpotPrice, 860_562_201_937_509_465, "rawSpotPrice0");
        assertEq(reserves[0].actualQuoteToken, WETH_MAINNET, "actualQuoteToken0");
        assertEq(reserves[1].token, WETH_MAINNET, "token1");
        assertEq(reserves[1].reserveAmount, 44_087_497_349_652_362, "reserveAmount1");
        assertEq(reserves[1].rawSpotPrice, 860_562_201_937_509_465, "rawSpotPrice1");
        assertEq(reserves[1].actualQuoteToken, WSTETH_MAINNET, "actualQuoteToken1");
    }
}
