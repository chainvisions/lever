pragma solidity 0.5.16;

interface ILendingPoolToken {
    function mint(address _to, uint256 _amount) external;
    function burn(address _from, uint256 _amount) external;
    function totalSupply() external view returns (uint256);
}