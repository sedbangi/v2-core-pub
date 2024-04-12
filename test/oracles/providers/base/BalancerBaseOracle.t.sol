// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

// solhint-disable func-name-mixedcase,var-name-mixedcase

import { Test } from "forge-std/Test.sol";

import { IERC20 } from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import { IBalancerComposableStablePool } from "src/interfaces/external/balancer/IBalancerComposableStablePool.sol";
import { IVault } from "src/interfaces/external/balancer/IVault.sol";
import { ISystemRegistry } from "src/interfaces/ISystemRegistry.sol";
import { IRootPriceOracle } from "src/interfaces/oracles/IRootPriceOracle.sol";
import { ISpotPriceOracle } from "src/interfaces/oracles/ISpotPriceOracle.sol";
import { BalancerBaseOracle } from "src/oracles/providers/base/BalancerBaseOracle.sol";
import { BalancerUtilities } from "src/libs/BalancerUtilities.sol";
import { Errors } from "src/utils/Errors.sol";

import {
    BAL_VAULT,
    USDC_MAINNET,
    DAI_MAINNET,
    USDT_MAINNET,
    WSTETH_MAINNET,
    RETH_MAINNET,
    SFRXETH_MAINNET,
    WETH_MAINNET,
    WSETH_RETH_SFRXETH_BAL_POOL,
    CBETH_WSTETH_BAL_POOL,
    CBETH_MAINNET,
    RETH_WETH_BAL_POOL
} from "test/utils/Addresses.sol";

/// @dev Universal wrapper for testing both Composable and Meta Stable Balancer pools
contract BalancerBaseOracleWrapper is BalancerBaseOracle {
    constructor(
        ISystemRegistry _systemRegistry,
        IVault _balancerVault
    ) BalancerBaseOracle(_systemRegistry, _balancerVault) { }

    function getTotalSupply_(address lpToken) internal virtual override returns (uint256 totalSupply) {
        totalSupply = BalancerUtilities.isComposablePool(lpToken)
            ? IBalancerComposableStablePool(lpToken).getActualSupply()
            : IERC20(lpToken).totalSupply();
    }

    function getPoolTokens_(address pool)
        internal
        virtual
        override
        returns (IERC20[] memory tokens, uint256[] memory balances)
    {
        (tokens, balances) = BalancerUtilities.isComposablePool(pool)
            ? BalancerUtilities._getComposablePoolTokensSkipBpt(balancerVault, pool)
            : BalancerUtilities._getPoolTokens(balancerVault, pool);
    }
}

contract BalancerBaseOracleWrapperTests is Test {
    IVault internal constant VAULT = IVault(BAL_VAULT);
    IRootPriceOracle private rootPriceOracle;
    ISystemRegistry private systemRegistry;
    BalancerBaseOracleWrapper internal oracle;

    uint256 private mainnetFork;

    function setUp() public virtual {
        mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"), 17_378_951);
        vm.selectFork(mainnetFork);

        rootPriceOracle = IRootPriceOracle(vm.addr(324));
        systemRegistry = generateSystemRegistry(address(rootPriceOracle));
        oracle = new BalancerBaseOracleWrapper(systemRegistry, VAULT);
    }

    function generateSystemRegistry(address rootOracle) internal returns (ISystemRegistry) {
        address registry = vm.addr(327_849);
        vm.mockCall(registry, abi.encodeWithSelector(ISystemRegistry.rootPriceOracle.selector), abi.encode(rootOracle));
        return ISystemRegistry(registry);
    }
}

contract GetSpotPrice is BalancerBaseOracleWrapperTests {
    /// @dev rEth -> sfrxETH at block 17_378_951 is 1.029499830936747431.
    /// Pool has no WETH so it returns sfrxETH
    function test_getSpotPrice_withWETHQuote() public {
        (uint256 price, address quoteToken) =
            oracle.getSpotPrice(RETH_MAINNET, WSETH_RETH_SFRXETH_BAL_POOL, WETH_MAINNET);

        assertEq(quoteToken, SFRXETH_MAINNET);
        assertEq(price, 1_029_499_830_936_747_431);
    }

    /// @dev rEth -> wstETH at block 17_378_951 is 0.952518727388269243.
    function test_getSpotPrice_withoutWETHQuote() public {
        (uint256 price, address quoteToken) = oracle.getSpotPrice(
            RETH_MAINNET, // rEth
            WSETH_RETH_SFRXETH_BAL_POOL,
            WSTETH_MAINNET // wstETH
        );

        assertEq(quoteToken, WSTETH_MAINNET);
        assertEq(price, 952_518_727_388_269_243);
    }
}

contract GetSafeSpotPriceInfo is BalancerBaseOracleWrapperTests {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_getSafeSpotPrice_RevertIfZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(Errors.ZeroAddress.selector, "pool"));
        oracle.getSafeSpotPriceInfo(address(0), WSETH_RETH_SFRXETH_BAL_POOL, WETH_MAINNET);

        vm.expectRevert(abi.encodeWithSelector(Errors.ZeroAddress.selector, "lpToken"));
        oracle.getSafeSpotPriceInfo(WSETH_RETH_SFRXETH_BAL_POOL, address(0), WETH_MAINNET);

        vm.expectRevert(abi.encodeWithSelector(Errors.ZeroAddress.selector, "quoteToken"));
        oracle.getSafeSpotPriceInfo(WSETH_RETH_SFRXETH_BAL_POOL, WSETH_RETH_SFRXETH_BAL_POOL, address(0));
    }

    function test_getSafeSpotPriceInfo() public {
        (uint256 totalLPSupply, ISpotPriceOracle.ReserveItemInfo[] memory reserves) =
            oracle.getSafeSpotPriceInfo(WSETH_RETH_SFRXETH_BAL_POOL, WSETH_RETH_SFRXETH_BAL_POOL, WETH_MAINNET);

        assertEq(reserves.length, 3);
        assertEq(totalLPSupply, 22_960_477_413_652_244_357_906);
        assertEq(reserves[0].token, WSTETH_MAINNET);
        assertEq(reserves[0].reserveAmount, 7_066_792_475_374_351_999_170);
        assertEq(reserves[0].rawSpotPrice, 1_049_846_558_967_442_743);
        assertEq(reserves[0].actualQuoteToken, RETH_MAINNET);
        assertEq(reserves[1].token, SFRXETH_MAINNET);
        assertEq(reserves[1].reserveAmount, 7_687_228_718_047_274_083_418);
        assertEq(reserves[1].rawSpotPrice, 971_344_086_447_801_818);
        assertEq(reserves[1].actualQuoteToken, RETH_MAINNET);
        assertEq(reserves[2].token, RETH_MAINNET);
        assertEq(reserves[2].reserveAmount, 6_722_248_966_013_056_226_285);
        assertEq(reserves[2].rawSpotPrice, 1_029_499_830_936_747_431);
        assertEq(reserves[2].actualQuoteToken, SFRXETH_MAINNET);
    }

    function test_getSafeSpotPriceInfo_UsdBasedPool() public {
        address USDC_DAI_USDT_COMPSTABLE = 0x79c58f70905F734641735BC61e45c19dD9Ad60bC;

        (uint256 totalLPSupply, ISpotPriceOracle.ReserveItemInfo[] memory reserves) =
            oracle.getSafeSpotPriceInfo(USDC_DAI_USDT_COMPSTABLE, USDC_DAI_USDT_COMPSTABLE, WETH_MAINNET);

        assertEq(reserves.length, 3, "rl");
        assertEq(totalLPSupply, 4_351_658_079_624_087_001_833_240, "lpSupply");
        assertEq(reserves[0].token, DAI_MAINNET, "zeroToken");
        assertEq(reserves[0].reserveAmount, 1_763_357_455_402_916_823_249_116, "zeroReserve");
        assertEq(reserves[0].rawSpotPrice, 999_603, "zeroRaw");
        assertEq(reserves[0].actualQuoteToken, USDT_MAINNET, "zeroActual");
        assertEq(reserves[1].token, USDC_MAINNET, "oneToken");
        assertEq(reserves[1].reserveAmount, 1_644_631_949_309, "oneReserve");
        assertEq(reserves[1].rawSpotPrice, 999_636, "oneRaw");
        assertEq(reserves[1].actualQuoteToken, USDT_MAINNET, "oneActual");
        assertEq(reserves[2].token, USDT_MAINNET, "twoToken");
        assertEq(reserves[2].reserveAmount, 946_215_901_433, "twoReserve");
        assertEq(reserves[2].rawSpotPrice, 1_000_362, "twoRaw");
        assertEq(reserves[2].actualQuoteToken, USDC_MAINNET, "twoActual");
    }

    function test_getSafeSpotPriceInfo_CbEthWstEthPool() public {
        (uint256 totalLPSupply, ISpotPriceOracle.ReserveItemInfo[] memory reserves) =
            oracle.getSafeSpotPriceInfo(CBETH_WSTETH_BAL_POOL, CBETH_WSTETH_BAL_POOL, WETH_MAINNET);

        assertEq(reserves.length, 2, "rl");
        assertEq(totalLPSupply, 18_041_051_911_925_925_865_156, "lpSupply");
        assertEq(reserves[0].token, WSTETH_MAINNET, "zeroToken");
        assertEq(reserves[0].reserveAmount, 7_153_059_635_966_264_986_141, "zeroReserve");
        assertEq(reserves[0].rawSpotPrice, 1_089_649_280_260_059_986, "zeroRaw");
        assertEq(reserves[0].actualQuoteToken, CBETH_MAINNET, "zeroActual");
        assertEq(reserves[1].token, CBETH_MAINNET, "oneToken");
        assertEq(reserves[1].reserveAmount, 9_804_597_003_965_141_038_572, "oneReserve");
        assertEq(reserves[1].rawSpotPrice, 917_721_864_937_790_959, "oneRaw");
        assertEq(reserves[1].actualQuoteToken, WSTETH_MAINNET, "oneActual");
    }

    function test_getSafeSpotPriceInfo_RethWethPool() public {
        (uint256 totalLPSupply, ISpotPriceOracle.ReserveItemInfo[] memory reserves) =
            oracle.getSafeSpotPriceInfo(RETH_WETH_BAL_POOL, RETH_WETH_BAL_POOL, WETH_MAINNET);

        assertEq(reserves.length, 2, "rl");
        assertEq(totalLPSupply, 41_458_365_247_894_236_652_969, "lpSupply");
        assertEq(reserves[0].token, RETH_MAINNET, "zeroToken");
        assertEq(reserves[0].reserveAmount, 19_543_079_911_395_563_931_751, "zeroReserve");
        assertEq(reserves[0].rawSpotPrice, 1_073_057_914_192_517_589, "zeroRaw");
        assertEq(reserves[0].actualQuoteToken, WETH_MAINNET, "zeroActual");
        assertEq(reserves[1].token, WETH_MAINNET, "oneToken");
        assertEq(reserves[1].reserveAmount, 21_445_519_175_513_497_135_889, "oneReserve");
        assertEq(reserves[1].rawSpotPrice, 931_914_363_128_563_237, "oneRaw");
        assertEq(reserves[1].actualQuoteToken, RETH_MAINNET, "oneActual");
    }

    function test_InvalidPoolReverts() public {
        address mockPool = vm.addr(3434);
        bytes32 badPoolId = keccak256("x2349382440328");
        vm.mockCall(
            mockPool, abi.encodeWithSelector(IBalancerComposableStablePool.getPoolId.selector), abi.encode(badPoolId)
        );
        vm.mockCall(mockPool, abi.encodeWithSelector(IERC20.totalSupply.selector), abi.encode(1));
        vm.expectRevert("BAL#500");
        oracle.getSafeSpotPriceInfo(mockPool, mockPool, WETH_MAINNET);
    }
}
