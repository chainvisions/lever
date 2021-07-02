// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./System.sol";

contract Manageable {

    System public system;

    constructor(address _system) {
        require(_system != address(0), "Manageable: System cannot be 0");
        system = System(_system);
    }

    modifier onlyGovernance {
        require(system.isGovernance(msg.sender), "Manageable: Caller is not Governance");
        _;
    }

    modifier onlyController {
        require(system.isController(msg.sender), "Manageable: Caller is not Controller");
        _;
    }

    modifier onlyPositionManager {
        require(system.isPositionManager(msg.sender), "Manageable: Caller is not PositionManager");
        _;
    }

    function setSystem(address _system) public onlyGovernance {
        system = System(_system);
    }

    function governance() public view returns (address) {
        return system.governance();
    }

    function controller() public view returns (address) {
        return system.controller();
    }

    function positionManager() public view returns (address) {
        return system.positionManager();
    }

}