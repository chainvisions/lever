// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./System.sol";

contract Governable {

    System public system;

    constructor(address _system) {
        require(_system != address(0), "Governable: System cannot be 0");
        system = System(_system);
    }

    modifier onlyGovernance {
        require(system.isGovernance(msg.sender), "Governable: Caller is not Governance");
        _;
    }

    function setSystem(address _system) public onlyGovernance {
        system = System(_system);
    }

    function governance() public view returns (address) {
        return system.governance();
    }

}