pragma solidity 0.5.16;

interface IPositionManager {
    function openPosition(address _strategy) external; 
    function collateral() external view returns (address);
    function principal() external view returns (address);
}