pragma solidity 0.5.16;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./Controllable.sol"; // TODO: Create a new Controllable that supports proxies.
import "./BaseStrategyStorage.sol";

contract BaseStrategy is Initializable, BaseStrategyStorage {
    constructor() public BaseStrategyStorage() {

    }

    function initialize(uint256 _delay) public initializer  {
        _setNextImplementationDelay(_delay);
    }

}