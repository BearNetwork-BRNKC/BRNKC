//SPDX-License-Identifier: MIT
//BearNetworkChain - BRNKC - From TAIWAN https://bearnetwork.net

pragma solidity >0.5.16 <1.0.0;

import "@openzeppelin/contracts-upgradeable@4.8.0/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.0/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.0/token/ERC20/extensions/ERC20SnapshotUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.0/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.0/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.0/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.0/proxy/utils/UUPSUpgradeable.sol";

/// @custom:security-contact bnkt@bearnetwork.net
contract BearNetworkV2 is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20SnapshotUpgradeable, OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable {
    mapping(address => bool) private _blacklist;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC20_init("BearNetworkChain", "BRNKC");
        __ERC20Burnable_init();
        __ERC20Snapshot_init();
        __Ownable_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    function snapshot() public onlyOwner {
        _snapshot();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function addToBlacklist(address account) public onlyOwner {
        _blacklist[account] = true;
    }

    function removeFromBlacklist(address account) public onlyOwner {
        _blacklist[account] = false;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklist[account];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20Upgradeable, ERC20SnapshotUpgradeable)
    {
        require(!_blacklist[from], "Sender is blacklisted");
        require(!_blacklist[to], "Recipient is blacklisted");

        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}