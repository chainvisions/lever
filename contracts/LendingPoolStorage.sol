// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

/// @title Lending Pool Storage
/// @author Chainvisions
/// @dev Storage for lending pool variables.

contract LendingPoolStorage {
    /// @notice Underlying token of the pool.
    address public underlying;

    /// @notice Vault to deposit capital in.
    address public vault;

    /// @notice Percentage of deposits to put to work.
    uint256 public efficiencyNumerator;

    /// @notice Safe percentage of utilization for capital efficiency.
    uint256 public safeUtilization;

    /// @notice Whitelist for contracts for a guarded launch.
    mapping(address => bool) public whitelist;

    /// @notice Guarded launch.
    bool public guarded;

    uint256 internal constant _PRECISION = 10000;

    event Deposit(address indexed from, uint256 amount);

    /// @notice Prevents interactions from contracts.
    modifier defense {
        require(
            msg.sender == tx.origin 
            || whitelist[msg.sender] 
            || !guarded,
            "LendingPool: Guarded launch in place"
        );
        _;
    }
}