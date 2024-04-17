// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

// solhint-disable no-console

import { console } from "forge-std/console.sol";

import { BaseScript, Systems } from "script/BaseScript.sol";
import { BalancerLPMetaStableEthOracle } from "src/oracles/providers/BalancerLPMetaStableEthOracle.sol";
import { RootPriceOracle } from "src/oracles/RootPriceOracle.sol";
import { IVault } from "src/interfaces/external/balancer/IVault.sol";
import { ISpotPriceOracle } from "src/interfaces/oracles/ISpotPriceOracle.sol";

/**
 * @dev This script sets token addresses and max ages on `CustomSetOracle.sol`, as well as setting
 *      the custom set oracle as the price oracle for the token on `RootPriceOracle.sol`.
 *
 * @dev Set state variables before running script against mainnet.
 */
contract SetupBalancerMetaOracle is BaseScript {
    function run() external {
        setUp(Systems.LST_GEN1_MAINNET);

        vm.startBroadcast(vm.envUint(constants.privateKeyEnvVar));

        BalancerLPMetaStableEthOracle oracle =
            new BalancerLPMetaStableEthOracle(systemRegistry, IVault(constants.ext.balancerVault));

        console.log("Bal Meta Oracle", address(oracle));

        RootPriceOracle rootPriceOracle = RootPriceOracle(address(systemRegistry.rootPriceOracle()));

        rootPriceOracle.replacePoolMapping(
            0x1E19CF2D73a72Ef1332C882F20534B6519Be0276,
            ISpotPriceOracle(0xfB625b5a7b2d6Be83dAcB9dEf6864233ec683da8),
            oracle
        );

        vm.stopBroadcast();
    }
}
