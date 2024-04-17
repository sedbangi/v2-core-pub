// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

// solhint-disable max-states-count
// solhint-disable no-console

import { console } from "forge-std/console.sol";
import { StatsCalculatorRegistry } from "src/stats/StatsCalculatorRegistry.sol";
import { StatsCalculatorFactory } from "src/stats/StatsCalculatorFactory.sol";

// Calculators
import { CurvePoolNoRebasingCalculatorBase } from "src/stats/calculators/base/CurvePoolNoRebasingCalculatorBase.sol";

// Libraries
import { BaseScript } from "script/BaseScript.sol";
import { Systems } from "../../utils/Constants.sol";
import { Stats } from "src/stats/Stats.sol";

contract DeployOsEthReth is BaseScript {
    bytes32 internal curveV1PoolNRSTemplateId = keccak256("curve-v1-pool-nr");

    StatsCalculatorRegistry internal statsRegistry;
    StatsCalculatorFactory internal statsFactory;

    function run() external {
        setUp(Systems.LST_GEN1_MAINNET);

        statsRegistry = StatsCalculatorRegistry(address(systemRegistry.statsCalculatorRegistry()));
        statsFactory = StatsCalculatorFactory(address(statsRegistry.factory()));

        bytes32[] memory osEthrEthDepIds = new bytes32[](2);
        osEthrEthDepIds[0] = Stats.generateRawTokenIdentifier(constants.tokens.osEth);
        osEthrEthDepIds[1] = keccak256(abi.encode("erc20-v2-", constants.tokens.rEth));

        vm.startBroadcast();

        _setupCurvePoolNoRebasingCalculatorBase(
            "osETH/rETH", curveV1PoolNRSTemplateId, osEthrEthDepIds, 0xe080027Bd47353b5D1639772b4a75E9Ed3658A0d
        );

        vm.stopBroadcast();
    }

    function _setupCurvePoolNoRebasingCalculatorBase(
        string memory title,
        bytes32 aprTemplateId,
        bytes32[] memory dependentAprIds,
        address poolAddress
    ) internal {
        CurvePoolNoRebasingCalculatorBase.InitData memory initData =
            CurvePoolNoRebasingCalculatorBase.InitData({ poolAddress: poolAddress });
        bytes memory encodedInitData = abi.encode(initData);

        address calculatorAddress = statsFactory.create(aprTemplateId, dependentAprIds, encodedInitData);
        console.log("-----------------");

        console.log(string.concat(title, " calculator address: "), calculatorAddress);
        console.log(
            "lastSnapshotTimestamp: ",
            CurvePoolNoRebasingCalculatorBase(calculatorAddress).current().lastSnapshotTimestamp
        );

        console.log("-----------------");
    }
}
