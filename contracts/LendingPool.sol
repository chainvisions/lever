// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

import {IERC3256Flashborrower} from "openzeppelin/contracts/interfaces/IERC3256.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {LendingPoolStorage} from "./LendingPoolStorage.sol";

/// @title Lever Lending Pool
/// @author Chainvisions
/// @notice Lending pool for Lever Protocol

contract LendingPool is LendingPoolStorage, ERC20Upgradeable {
    using SafeERC20 for IERC20;

    function initialize(
        address _underlying
    ) external initializer {
        underlying = _underlying;
    }

    /// @dev Function to supply funds into the lending pool.
    /// @param _amount Amount to supply.
    function deposit(uint256 _amount) external defense {
        uint256 toMint = totalSupply() == 0 
            ? _amount 
            : (_amount * totalTokens()) / totalSupply();
        _mint(msg.sender, toMint);
        IERC20(underlying).safeTransferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount);
    }

    /// @dev Provides liquidity for a flashloan.
    /// @param _receiver Contract to receive the flashloan callback.
    /// @param _amount Amount to borrow from the lending pool.
    function flashloan(
        IERC3256Flashborrower _receiver, 
        uint256 _amount,
        bytes32 calldata _data
    ) external {
        require(!guarded, "LendingPool: Guarded launch phase active");
        require(_amount < totalTokens(), "LendingPool: Cannot borrow more than the pool's liquidity");
        uint256 fee = (_amount * flashloanFee) / _PRECISION;
        uint256 total = _amount + fee;

        require(_receiver.onFlashLoan(msg.sender, underlying, _amount, fee, _data) == _RETURN_DATA, "LendingPool: Invalid return value");

    }

    /// @dev Function used to view how many tokens are in the pool.
    /// @return The amount of tokens the pool holds.
    function totalTokens() public view returns (uint256) {
        return IERC20(underlying).balanceOf(address(this));
    }
}