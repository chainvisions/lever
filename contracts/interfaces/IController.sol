pragma solidity 0.5.16;

interface IController {
    function collateral() external view returns (address);
    function principal() external view returns (address);
}