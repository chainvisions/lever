pragma solidity 0.5.16;

import "./System.sol";

contract Controllable {

    System public system;

    constructor(address _system) public {
        require(_system != address(0), "Controllable: System cannot be 0");
        system = System(_system);
    }

    modifier onlyGovernance {
        require(system.isGovernance(msg.sender), "Controllable: Caller is not Governance");
        _;
    }

    modifier onlyController {
        require(system.isController(msg.sender), "Controllable: Caller is not Controller");
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

}