pragma solidity 0.8.6;

interface IComptroller {
    function markets(address _vtoken) external view returns (bool, uint256, bool);
    function getAccountLiquidity(address _account) external view returns (uint256, uint256, uint256);
    function claimVenus(address _holder) external;
}