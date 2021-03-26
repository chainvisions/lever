pragma solidity 0.5.16;

interface IPosition {
    function supplyCollateral(uint256 _amount) external;
    function harvestAndCompound() external;
}