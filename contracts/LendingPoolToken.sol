pragma solidity 0.5.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";

contract LendingPoolToken is ERC20, ERC20Detailed, ERC20Mintable {

    constructor(string memory _name, string memory _symbol) public ERC20Detailed(_name, _symbol, 18) {}

    /**
    * Allows for remotely burning tokens. This is used by the lending pool to allow
    * for the lending pool token to be redeemed.
     */
    function burn(address _from, uint256 _amount) public onlyMinter {
        _burn(_from, _amount);
    }
}