// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable@v4.7.3/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable@v4.7.3/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@v4.7.3/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@v4.7.3/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@v4.7.3/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable@v4.7.3/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@v4.7.3/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@v4.7.3/token/ERC20/extensions/ERC20CappedUpgradeable.sol";

/// @custom:security-contact security@example.com
contract ROMB is
Initializable,
ERC20Upgradeable,
ERC20PermitUpgradeable,
ERC20VotesUpgradeable,
PausableUpgradeable,
ERC20CappedUpgradeable,
OwnableUpgradeable,
UUPSUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC20_init("ROMB GAME TOKEN", "RMB");
        __ERC20Permit_init("ROMB GAME TOKEN");
        __ERC20Votes_init();
        __Pausable_init();
        __ERC20Capped_init(1000000000 * 10**decimals());
        __Ownable_init();
        __UUPSUpgradeable_init();

        _mint(msg.sender, 1000000000 * 10**decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyOwner
    {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
    internal
    override(
        ERC20Upgradeable,
        ERC20VotesUpgradeable,
        ERC20CappedUpgradeable
    )
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
    internal
    override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._burn(account, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}
