pragma solidity 0.5.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";
import "../Governable.sol";

contract LeverToken is ERC20, ERC20Detailed, ERC20Mintable, Governable {

    constructor(address _system) public 
    Governable(_system) ERC20Detailed("Lever Protocol", "LVR", 18) 
    {
        renounceMinter();
        _addMinter(governance());
    }

    function addMinter(address _minter) public onlyGovernance {
        super.addMinter(_minter);
    }

}