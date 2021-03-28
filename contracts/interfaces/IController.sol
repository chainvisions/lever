pragma solidity 0.5.16;

interface IController {
    function strategyApproved(address _strategy) external view returns (bool);
    function performanceFeeNumerator() external view returns (uint256);
    function performanceFeeDenominator() external view returns (uint256);
    function collateral() external view returns (address);
    function principal() external view returns (address);
}