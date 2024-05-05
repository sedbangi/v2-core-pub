// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.

pragma solidity 0.8.17;

library Roles {
    // --------------------------------------------------------------------
    // Central roles list used by all contracts that call AccessController
    // --------------------------------------------------------------------
    // TODO: Update the hash values to match the variable names for new deployments.

    // Naming Conventions:
    // - Use MANAGER, CREATOR, UPDATER, ..., for roles primarily managing on-chain activities.
    // - Use EXECUTOR for roles that trigger off-chain initiated actions.
    // - Group roles by functional area for clarity.
    // --------------------------------------------------------------------

    // Destination Vault Management
    bytes32 public constant DESTINATION_VAULT_FACTORY_MANAGER = keccak256("CREATE_DESTINATION_VAULT_ROLE");
    bytes32 public constant DESTINATION_VAULT_REGISTRY_MANAGER = keccak256("DESTINATION_VAULT_REGISTRY_MANAGER");
    bytes32 public constant DESTINATION_VAULT_MANAGER = keccak256("DESTINATION_VAULT_MANAGER");

    // Auto Pool Factory and Registry Management
    bytes32 public constant AUTO_POOL_REGISTRY_UPDATER = keccak256("REGISTRY_UPDATER");
    bytes32 public constant AUTO_POOL_FACTORY_MANAGER = 0x00; // keccak256("LMP_VAULT_FACTORY_MANAGER");
    bytes32 public constant AUTO_POOL_FACTORY_VAULT_CREATOR = keccak256("CREATE_POOL_ROLE");

    // Auto Pool Management
    bytes32 public constant AUTO_POOL_DESTINATION_UPDATER = keccak256("DESTINATION_VAULTS_UPDATER");
    bytes32 public constant AUTO_POOL_FEE_UPDATER = keccak256("AUTO_POOL_FEE_SETTER_ROLE");
    bytes32 public constant AUTO_POOL_PERIODIC_FEE_UPDATER = keccak256("AUTO_POOL_PERIODIC_FEE_SETTER_ROLE");
    bytes32 public constant AUTO_POOL_REWARD_MANAGER = keccak256("AUTO_POOL_REWARD_MANAGER_ROLE");
    bytes32 public constant AUTO_POOL_MANAGER = keccak256("AUTO_POOL_ADMIN");
    bytes32 public constant REBALANCER = keccak256("REBALANCER_ROLE");

    // Reward Management
    bytes32 public constant LIQUIDATOR_MANAGER = keccak256("LIQUIDATOR_ROLE");
    bytes32 public constant DV_REWARD_MANAGER = keccak256("DV_REWARD_MANAGER_ROLE");
    bytes32 public constant REWARD_LIQUIDATION_MANAGER = keccak256("REWARD_LIQUIDATION_MANAGER");
    bytes32 public constant EXTRA_REWARD_MANAGER = keccak256("EXTRA_REWARD_MANAGER_ROLE");
    bytes32 public constant REWARD_LIQUIDATION_EXECUTOR = keccak256("REWARD_LIQUIDATION_EXECUTOR");

    // Statistics and Reporting
    bytes32 public constant STATS_CALC_REGISTRY_MANAGER = 0x00; // keccak256("STATS_CALC_REGISTRY_MANAGER");
    bytes32 public constant STATS_CALC_FACTORY_MANAGER = keccak256("CREATE_STATS_CALC_ROLE");
    bytes32 public constant STATS_CALC_FACTORY_TEMPLATE_MANAGER = keccak256("STATS_CALC_TEMPLATE_MGMT_ROLE");

    bytes32 public constant STATS_SNAPSHOT_EXECUTOR = keccak256("STATS_SNAPSHOT_ROLE");
    bytes32 public constant STATS_INCENTIVE_TOKEN_UPDATER = keccak256("STATS_INCENTIVE_TOKEN_UPDATER");
    bytes32 public constant STATS_GENERAL_MANAGER = keccak256("STATS_GENERAL_MANAGER");

    // Emergency Management
    bytes32 public constant EMERGENCY_PAUSER = keccak256("EMERGENCY_PAUSER");

    // Miscellaneous Roles
    bytes32 public constant SOLVER = keccak256("SOLVER_ROLE");
    bytes32 public constant AUTO_POOL_REPORTING_EXECUTOR = keccak256("AUTO_POOL_UPDATE_DEBT_REPORTING_ROLE");

    // Swapper Roles
    bytes32 public constant SWAP_ROUTER_MANAGER = 0x00; // keccak256("SWAP_ROUTER_MANAGER");

    // Price Oracles Roles
    bytes32 public constant ORACLE_MANAGER = keccak256("ORACLE_MANAGER_ROLE");
    bytes32 public constant CUSTOM_ORACLE_EXECUTOR = keccak256("CUSTOM_ORACLE_EXECUTOR");
    bytes32 public constant MAVERICK_FEE_ORACLE_EXECUTOR = keccak256("MAVERICK_FEE_ORACLE_MANAGER");

    // AccToke Roles
    bytes32 public constant ACC_TOKE_MANAGER = keccak256("ACC_TOKE_MANAGER");

    // Admin Roles
    bytes32 public constant TOKEN_RECOVERY_MANAGER = keccak256("TOKEN_RECOVERY_ROLE");
}
