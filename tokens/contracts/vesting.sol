// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract VestingWallet is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    event ERC20Released(address indexed beneficiaryAddress, uint256 amount);
    event VestingCreated(address indexed beneficiaryAddress, uint256 amount);

    mapping(address => uint256) public amount;
    mapping(address => uint256) public released;
    mapping(address => uint256) public cliff;
    mapping(address => uint64) public duration;
    mapping(address => string) public note;

    uint256 public debt;
    address public token;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function createVesting(
        address beneficiaryAddress,
        uint64 durationSeconds,
        uint256 cliffSeconds,
        uint256 _amount,
        string memory _note
    ) external onlyOwner {
        require(
            beneficiaryAddress != address(0),
            "VestingWallet: beneficiary is zero address"
        );

        require(
            durationSeconds < 5 * 12 * 30 * 24 * 60 * 60,
            "VestingWallet: duration must be less then 5 years"
        );

        require(
            cliffSeconds < 3 * 12 * 30 * 24 * 60 * 60,
            "VestingWallet: cliff must be less then 3 years"
        );

        require(_amount > 0, "VestingWallet: amount must be greater then 0");

        require(
            IERC20Upgradeable(token).balanceOf(address(this)) >=
                (debt + _amount),
            "VestingWallet: not enough tokens to vest required amount"
        );

        require(
            amount[beneficiaryAddress] == 0,
            "VestingWallet: already vesting for beneficiaryAddress"
        );

        amount[beneficiaryAddress] = _amount;
        released[beneficiaryAddress] = 0;
        cliff[beneficiaryAddress] = uint64(block.timestamp) + cliffSeconds;
        duration[beneficiaryAddress] = durationSeconds;
        note[beneficiaryAddress] = _note;

        debt += _amount;

        emit VestingCreated(beneficiaryAddress, _amount);
    }

    function setToken(address _token) public onlyOwner {
        require(_token != address(0), "Token cannot be null");
        require(token == address(0), "Token already set");

        token = _token;
    }

    function release(address beneficiaryAddress) public {
        uint256 releasable = vestedAmount(
            beneficiaryAddress,
            uint64(block.timestamp)
        ) - released[beneficiaryAddress];

        require(releasable > 0, "No tokens to release");

        released[beneficiaryAddress] += releasable;
        debt -= releasable;

        emit ERC20Released(beneficiaryAddress, releasable);

        SafeERC20Upgradeable.safeTransfer(
            IERC20Upgradeable(token),
            beneficiaryAddress,
            releasable
        );
    }

    function vestedAmount(address beneficiaryAddress, uint64 timestamp)
        public
        view
        returns (uint256)
    {
        return
            _vestingSchedule(
                beneficiaryAddress,
                amount[beneficiaryAddress],
                timestamp
            );
    }

    function _vestingSchedule(
        address beneficiaryAddress,
        uint256 totalAllocation,
        uint64 timestamp
    ) internal view returns (uint256) {
        if (timestamp < cliff[beneficiaryAddress]) {
            return 0;
        } else if (
            timestamp > cliff[beneficiaryAddress] + duration[beneficiaryAddress]
        ) {
            return totalAllocation;
        } else {
            return
                (totalAllocation * (timestamp - cliff[beneficiaryAddress])) /
                duration[beneficiaryAddress];
        }
    }
}
