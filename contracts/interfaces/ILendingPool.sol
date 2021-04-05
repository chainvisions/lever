pragma solidity 0.5.16;

interface ILendingPool {
    // Deposit tokens into the lending pool.
    function deposit(address _token, uint256 _amount) external;
    // Withdraw tokens from the lending pool.
    function withdraw(address _token, uint256 _amount) external;
    // Borrow tokens supplied in the lending pool.
    function borrow(uint256 _amount) external;
    // Liquidate the collateral of the specified address.
    function liquidate(address _token, uint256 _repayAmount) external;
    // Get how much of `_token` the lending pool holds.
    function tokenBalance(address _token) external view returns (uint256);
    // Get the price of the lToken equivalent of `_token`.
    function lTokenPrice(address _token) external view returns (uint256);
}