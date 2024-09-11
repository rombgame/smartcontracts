// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable@v4.7.3/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable@v4.7.3/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@v4.7.3/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@v4.7.3/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@v4.7.3/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable@v4.7.3/token/ERC20/extensions/ERC20CappedUpgradeable.sol";

/// @custom:security-contact security@example.com
contract ROMG is
    Initializable,
    ERC20Upgradeable,
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
        __ERC20_init("ROMB inGAME TOKEN", "RMG");
        __Pausable_init();
        __ERC20Capped_init(50000000000 * 10**decimals());
        __Ownable_init();
        __UUPSUpgradeable_init();

        _mint(msg.sender, 50000000000 * 10**decimals());
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

    function _mint(address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20CappedUpgradeable)
    {
        super._mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}
