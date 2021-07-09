pragma solidity ^0.8.0;

interface IPosition {
    function supplyCollateral(uint256 _amount) external;
    function harvestAndCompound() external;
    function marketSnapshot() external view returns (bool);
}