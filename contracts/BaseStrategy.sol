// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./Controllable.sol"; // TODO: Create a new Controllable that supports proxies.
import "./BaseStrategyStorage.sol";

contract BaseStrategy is Initializable, BaseStrategyStorage {
    constructor() BaseStrategyStorage() {

    }

    function initialize(uint256 _delay) public initializer  {
        _setNextImplementationDelay(_delay);
    }

}