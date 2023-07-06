// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17;

import { Roles } from "src/libs/Roles.sol";
import { Errors } from "src/utils/Errors.sol";
import { SecurityBase } from "src/security/SecurityBase.sol";
import { ERC20 } from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import { ISystemRegistry } from "src/interfaces/ISystemRegistry.sol";
import { ISwapRouter } from "src/interfaces/swapper/ISwapRouter.sol";
import { IMainRewarder } from "src/interfaces/rewarders/IMainRewarder.sol";
import { IDestinationVault } from "src/interfaces/vault/IDestinationVault.sol";
import { SafeERC20 } from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import { Initializable } from "openzeppelin-contracts/proxy/utils/Initializable.sol";
import { EnumerableSet } from "openzeppelin-contracts/utils/structs/EnumerableSet.sol";
import { IERC20Metadata as IERC20 } from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";

abstract contract DestinationVault is SecurityBase, ERC20, Initializable, IDestinationVault {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    event Recovered(address[] tokens, uint256[] amounts, address[] destinations);
    event UnderlyingWithdraw(uint256 amount, address owner, address to);
    event BaseAssetWithdraw(uint256 amount, address owner, address to);
    event UnderlyingDeposited(uint256 amount, address sender);

    error ArrayLengthMismatch();
    error PullingNonTrackedToken(address token);
    error RecoveringTrackedToken(address token);
    error RecoveringMoreThanAvailable(address token, uint256 amount, uint256 availableAmount);
    error DuplicateToken(address token);

    ISystemRegistry internal immutable _systemRegistry;

    /* ******************************** */
    /* State Variables                  */
    /* ******************************** */

    string internal _name;
    string internal _symbol;
    uint8 internal _underlyingDecimals;

    address internal _baseAsset;
    address internal _underlying;

    IMainRewarder internal _rewarder;

    EnumerableSet.AddressSet internal _trackedTokens;

    constructor(ISystemRegistry sysRegistry) SecurityBase(address(sysRegistry.accessController())) ERC20("", "") {
        _systemRegistry = sysRegistry;
    }

    modifier onlyOperator() {
        // TODO: Fix access control
        // if (!_hasRole(Roles.DESTINATION_VAULT_OPERATOR_ROLE, msg.sender)) revert Errors.AccessDenied();
        _;
    }

    modifier onlyLMPVault() {
        if (!_systemRegistry.lmpVaultRegistry().isVault(msg.sender)) {
            revert Errors.AccessDenied();
        }
        _;
    }

    function initialize(
        IERC20 baseAsset_,
        IERC20 underlyer_,
        IMainRewarder rewarder_,
        address[] memory additionalTrackedTokens_,
        bytes memory
    ) public virtual initializer {
        Errors.verifyNotZero(address(baseAsset_), "baseAsset_");
        Errors.verifyNotZero(address(underlyer_), "underlyer_");
        Errors.verifyNotZero(address(rewarder_), "rewarder_");

        _name = string.concat("Tokemak-", baseAsset_.name(), "-", underlyer_.name());
        _symbol = string.concat("toke-", baseAsset_.symbol(), "-", underlyer_.symbol());
        _underlyingDecimals = underlyer_.decimals();

        _baseAsset = address(baseAsset_);
        _underlying = address(underlyer_);
        _rewarder = rewarder_;

        // Setup the tracked tokens
        _addTrackedToken(address(baseAsset_));
        _addTrackedToken(address(underlyer_));
        uint256 attLen = additionalTrackedTokens_.length;
        for (uint256 i = 0; i < attLen; ++i) {
            _addTrackedToken(additionalTrackedTokens_[i]);
        }
    }

    /// @inheritdoc ERC20
    function name() public view virtual override(ERC20, IERC20) returns (string memory) {
        return _name;
    }

    /// @inheritdoc ERC20
    function symbol() public view virtual override(ERC20, IERC20) returns (string memory) {
        return _symbol;
    }

    /// @inheritdoc IDestinationVault
    function baseAsset() external view virtual override returns (address) {
        return _baseAsset;
    }

    /// @inheritdoc IDestinationVault
    function underlying() external view virtual override returns (address) {
        return _underlying;
    }

    /// @inheritdoc IDestinationVault
    function rewarder() external view virtual override returns (address) {
        return address(_rewarder);
    }

    /// @inheritdoc ERC20
    function decimals() public view virtual override(ERC20, IERC20) returns (uint8) {
        return _underlyingDecimals;
    }

    /// @inheritdoc IDestinationVault
    function debtValue() public virtual override returns (uint256 value) {
        uint256 price = _systemRegistry.rootPriceOracle().getPriceInEth(_underlying);
        uint256 ethValue = (price * (balanceOfUnderlying())) / (10 ** _underlyingDecimals);
        value = getTokenPriceInBaseAsset(ethValue);
    }

    /// @inheritdoc IDestinationVault
    function debtValue(uint256 shares) external virtual returns (uint256 value) {
        if (shares == 0) {
            return 0;
        }
        uint256 price = _systemRegistry.rootPriceOracle().getPriceInEth(_underlying);
        uint256 ethValue = (price * shares) / (10 ** _underlyingDecimals);
        value = getTokenPriceInBaseAsset(ethValue);
    }

    /// @inheritdoc IDestinationVault
    function exchangeName() external view virtual override returns (string memory);

    /// @inheritdoc IDestinationVault
    function underlyingTokens() external view virtual override returns (address[] memory);

    /// @inheritdoc IDestinationVault
    function collectRewards() external virtual override returns (uint256[] memory amounts, address[] memory tokens);

    /// @notice Figure out price in terms of the base asset
    function getTokenPriceInBaseAsset(uint256 currentEthValue) internal returns (uint256 value) {
        // If the base asset is WETH then we know its 1:1 to ETH so we'll just return the current value
        if (address(_baseAsset) == address(_systemRegistry.weth())) {
            return currentEthValue;
        }

        // Otherwise get the price of the base asset and convert
        uint256 baseAssetPriceInEth = _systemRegistry.rootPriceOracle().getPriceInEth(address(_baseAsset));

        // slither-disable-next-line divide-before-multiply
        value = currentEthValue * 1e18 / baseAssetPriceInEth;
    }

    function trackedTokens() public view virtual returns (address[] memory trackedTokensArr) {
        uint256 arLen = _trackedTokens.length();
        trackedTokensArr = new address[](arLen);
        for (uint256 i = 0; i < arLen; ++i) {
            trackedTokensArr[i] = _trackedTokens.at(i);
        }
    }

    /// @notice Checks if given token is tracked by Vault
    /// @param token Address to verify
    /// @return bool True if token is within Vault's tracked assets
    function isTrackedToken(address token) public view virtual returns (bool) {
        return _trackedTokens.contains(token);
    }

    /// @inheritdoc IDestinationVault
    function donate(uint256 amount) external onlyOperator {
        emit Donated(msg.sender, amount);

        IERC20(_underlying).safeTransferFrom(msg.sender, address(this), amount);

        _onDeposit(amount);
    }

    /// @inheritdoc IDestinationVault
    function depositUnderlying(uint256 amount) external onlyLMPVault returns (uint256 shares) {
        Errors.verifyNotZero(amount, "amount");

        IERC20(_underlying).safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);

        emit UnderlyingDeposited(amount, msg.sender);

        _onDeposit(amount);

        shares = amount;
    }

    /// @inheritdoc IDestinationVault
    function withdrawUnderlying(uint256 shares, address to) external onlyLMPVault returns (uint256 amount) {
        Errors.verifyNotZero(shares, "shares");
        Errors.verifyNotZero(to, "to");

        // Does a balance check, will revert if trying to burn too much
        _burn(msg.sender, shares);

        amount = shares;

        emit UnderlyingWithdraw(amount, msg.sender, to);

        _ensureLocalUnderlyingBalance(amount);

        IERC20(_underlying).safeTransfer(to, amount);
    }

    /// @inheritdoc IDestinationVault
    function balanceOfUnderlying() public view virtual override returns (uint256 shares);

    /// @notice Ensure that we have the specified balance of the underlyer in the vault itself
    /// @param amount amount of token
    function _ensureLocalUnderlyingBalance(uint256 amount) internal virtual;

    /// @notice Callback during a deposit after the sender has been minted shares (if applicable)
    /// @dev Should be used for staking tokens into protocols, etc
    /// @param amount underlying tokens received
    function _onDeposit(uint256 amount) internal virtual;

    /// @inheritdoc IDestinationVault
    function withdrawBaseAsset(uint256 shares, address to) external returns (uint256 amount) {
        Errors.verifyNotZero(shares, "shares");

        // Does a balance check, will revert if trying to burn too much
        _burn(msg.sender, shares);

        emit BaseAssetWithdraw(shares, msg.sender, to);

        // Accounts for shares that may be staked
        _ensureLocalUnderlyingBalance(shares);

        (address[] memory tokens, uint256[] memory amounts) = _burnUnderlyer(shares);

        uint256 nTokens = tokens.length;
        Errors.verifyArrayLengths(nTokens, amounts.length, "token+amounts");

        // Swap what we receive if not already in base asset
        // This fn is only called during a users withdrawal. The user should be making this
        // call via the LMP Router, or through one of the other routes where
        // slippage is controlled for. 0 min amount is expected here.
        ISwapRouter swapRouter = _systemRegistry.swapRouter();
        for (uint256 i = 0; i < nTokens; ++i) {
            address token = tokens[i];

            if (token == _baseAsset) {
                amount += amounts[i];
            } else {
                IERC20(token).safeApprove(address(swapRouter), amounts[i]);
                amount += swapRouter.swapForQuote(token, amounts[i], _baseAsset, 0);
            }
        }

        if (amount > 0) {
            IERC20(_baseAsset).safeTransfer(to, amount);
        }
    }

    /// @notice Burn the specified amount of underlyer for the constituent tokens
    /// @dev May return one or multiple assets. Be as efficient as you can here.
    /// @param underlyerAmount amount of underlyer to burn
    /// @return tokens the tokens to swap for base asset
    /// @return amounts the amounts we have to swap
    function _burnUnderlyer(uint256 underlyerAmount)
        internal
        virtual
        returns (address[] memory tokens, uint256[] memory amounts);

    function recover(
        address[] calldata tokens,
        uint256[] calldata amounts,
        address[] calldata destinations
    ) external override onlyOperator {
        uint256 length = tokens.length;
        if (length == 0 || length != amounts.length || length != destinations.length) {
            revert ArrayLengthMismatch();
        }
        emit Recovered(tokens, amounts, destinations);

        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20 token = IERC20(tokens[i]);

            // Check if it's a really non-tracked token
            if (isTrackedToken(tokens[i])) revert RecoveringTrackedToken(tokens[i]);

            uint256 tokenBalance = token.balanceOf(address(this));
            if (tokenBalance < amounts[i]) revert RecoveringMoreThanAvailable(tokens[i], amounts[i], tokenBalance);

            token.safeTransfer(destinations[i], amounts[i]);
        }
    }

    function _addTrackedToken(address token) internal {
        //slither-disable-next-line unused-return
        _trackedTokens.add(token);
    }
}
