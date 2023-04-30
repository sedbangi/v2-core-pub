// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IStakeTracking } from "src/interfaces/rewarders/IStakeTracking.sol";

contract StakeTrackingMock is IStakeTracking {
    function totalSupply() external pure returns (uint256) {
        return 100_000_000_000_000_000;
    }

    function balanceOf(address) external pure returns (uint256) {
        return 100_000_000_000_000_000;
    }
}
