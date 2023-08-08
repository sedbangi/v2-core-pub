// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

import { IERC20Metadata } from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IDestinationVault } from "src/interfaces/vault/IDestinationVault.sol";
import { ILMPVaultRegistry } from "src/interfaces/vault/ILMPVaultRegistry.sol";
import { ILMPVault } from "src/interfaces/vault/ILMPVault.sol";
import { ILens } from "src/interfaces/lens/ILens.sol";
import { SystemComponent } from "src/SystemComponent.sol";
import { ISystemRegistry } from "src/interfaces/ISystemRegistry.sol";
import { Errors } from "src/utils/Errors.sol";

contract Lens is ILens, SystemComponent {
    ILMPVaultRegistry public immutable lmpRegistry;

    constructor(ISystemRegistry _systemRegistry) SystemComponent(_systemRegistry) {
        ILMPVaultRegistry _lmpRegistry = _systemRegistry.lmpVaultRegistry();

        // System registry must be properly initialized first
        Errors.verifyNotZero(address(_lmpRegistry), "lmpRegistry");

        lmpRegistry = _lmpRegistry;
    }

    /// @inheritdoc ILens
    function getVaults() external view override returns (ILens.LMPVault[] memory lmpVaults) {
        address[] memory lmpAddresses = lmpRegistry.listVaults();
        lmpVaults = new ILens.LMPVault[](lmpAddresses.length);

        for (uint256 i = 0; i < lmpAddresses.length; ++i) {
            address vaultAddress = lmpAddresses[i];
            ILMPVault vault = ILMPVault(vaultAddress);
            lmpVaults[i] = ILens.LMPVault(vaultAddress, vault.name(), vault.symbol());
        }
    }

    /// @inheritdoc ILens
    function getVaultDestinations()
        external
        view
        override
        returns (address[] memory lmpVaults, ILens.DestinationVault[][] memory destinations)
    {
        lmpVaults = lmpRegistry.listVaults();
        destinations = new ILens.DestinationVault[][](lmpVaults.length);

        for (uint256 i = 0; i < lmpVaults.length; ++i) {
            destinations[i] = _getDestinations(lmpVaults[i]);
        }
    }

    /// @inheritdoc ILens
    function getVaultDestinationTokens()
        external
        view
        override
        returns (address[] memory destinationVaults, ILens.UnderlyingToken[][] memory tokens)
    {
        destinationVaults = new address[](_getDestinationsCount());
        address[] memory lmpVaults = lmpRegistry.listVaults();

        uint256 destArrPointer = 0;
        for (uint256 i = 0; i < lmpVaults.length; ++i) {
            address[] memory lmpDestinations = ILMPVault(lmpVaults[i]).getDestinations();

            for (uint256 j = 0; j < lmpDestinations.length; ++j) {
                destinationVaults[destArrPointer++] = lmpDestinations[j];
            }
        }

        tokens = new ILens.UnderlyingToken[][](destinationVaults.length);

        for (uint256 i = 0; i < destinationVaults.length; ++i) {
            tokens[i] = _getTokens(destinationVaults[i]);
        }
    }

    function _getDestinations(address lmpVault) private view returns (ILens.DestinationVault[] memory destinations) {
        address[] memory vaultDestinations = ILMPVault(lmpVault).getDestinations();
        destinations = new ILens.DestinationVault[](vaultDestinations.length);
        for (uint256 i = 0; i < vaultDestinations.length; ++i) {
            address destinationAddress = vaultDestinations[i];
            IDestinationVault destination = IDestinationVault(destinationAddress);
            destinations[i] = ILens.DestinationVault(destinationAddress, destination.exchangeName());
        }
    }

    function _getDestinationsCount() private view returns (uint256 count) {
        address[] memory lmpVaults = lmpRegistry.listVaults();

        for (uint256 i = 0; i < lmpVaults.length; ++i) {
            address[] memory lmpDestinations = ILMPVault(lmpVaults[i]).getDestinations();
            count += lmpDestinations.length;
        }
    }

    function _getTokens(address destinationVault) private view returns (ILens.UnderlyingToken[] memory tokens) {
        address[] memory destinationTokens = IDestinationVault(destinationVault).underlyingTokens();
        tokens = new ILens.UnderlyingToken[](destinationTokens.length);
        for (uint256 i = 0; i < destinationTokens.length; ++i) {
            address tokenAddress = destinationTokens[i];
            tokens[i] = ILens.UnderlyingToken(tokenAddress, IERC20Metadata(tokenAddress).symbol());
        }
    }
}
