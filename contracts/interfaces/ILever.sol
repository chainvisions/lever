pragma solidity 0.5.16;

interface ILever {
    function mint(address _to, uint256 _amount) external;
    function renounceMinter() external;
    function isMinter(address _addr) external view returns (bool);
}