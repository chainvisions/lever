pragma solidity ^0.8.0;

interface ILendingPool {
    // Deposit tokens into the lending pool.
    function deposit(uint256 _amount) external;
    // Withdraw tokens from the lending pool.
    function withdraw(uint256 _amount) external;
    // Borrow tokens supplied in the lending pool.
    function borrow(uint256 _amount) external;
    // Liquidate the collateral of the specified address.
    function liquidate(uint256 _repayAmount) external;
    // Get how much of the underlying token the pool holds.
    function tokenBalance() external view returns (uint256);
    // Get the price of the lending pool lToken.
    function lTokenPrice() external view returns (uint256);
}