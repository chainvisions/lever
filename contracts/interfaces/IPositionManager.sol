pragma solidity 0.5.16;

interface IPositionManager {
    function openPosition(address _strategy) external; 
    function userPositions(address _user) external view returns (address[] memory);
    // Determines if a position can be adjusted based on the market.
    function positionAdjustable(address _position) external view returns (bool);
    function positions(address _position) external view returns (bool);
}