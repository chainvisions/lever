// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {LendingPoolStorage} from "./LendingPoolStorage.sol";

/// @title Lever Lending Pool
/// @author Chainvisions
/// @notice Lending pool for Lever Protocol

contract LendingPool is LendingPoolStorage, ERC20Upgradeable {
    using SafeERC20 for IERC20;

    event Deposit(address indexed from, address indexed to, uint256 amount);

    function initialize(
        address _underlying
    ) external initializer {
        _setUnderlying(_underlying);
    }

    /// @dev Function to supply funds into the lending pool.
    /// @param _amount Amount to supply.
    function deposit(uint256 _amount) external {
        _deposit(msg.sender, msg.sender, _amount);
    }

    /// @dev Function to deposit for a specific address.
    /// @param _for Address to deposit for.
    /// @param _amount Amount to deposit.
    function depositFor(address _for, uint256 _amount) external {
        _deposit(msg.sender, _for, _amount);
    }

    function _deposit(address _from, address _to, uint256 _amount) internal {
        uint256 toMint = totalSupply() == 0
            ? _amount
            : (_amount * totalTokens()) / totalSupply();

        _mint(_to, toMint);
        IERC20(underlying()).safeTransferFrom(_from, address(this), _amount);
        emit Deposit(_from, _to, _amount);
    }

    /// @dev Function used to view how many tokens are in the pool.
    /// @return The amount of tokens the pool holds.
    function totalTokens() public view returns (uint256) {
        return IERC20(underlying()).balanceOf(address(this));
    }
}