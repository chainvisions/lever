pragma solidity 0.5.16;

interface IPositionManager {
    function openPosition(address _strategy) external; 
    function userPositions(address _user) external view returns (address[] memory);
}