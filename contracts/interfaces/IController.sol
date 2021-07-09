pragma solidity ^0.8.0;

interface IController {
    function strategyApproved(address _strategy) external view returns (bool);
    function performanceFeeNumerator() external view returns (uint256);
    function performanceFeeDenominator() external view returns (uint256);
    function collateral() external view returns (address);
    function principal() external view returns (address);
    function wbnb() external view returns (address);
    function bullOrBear() external view returns (bool);
}