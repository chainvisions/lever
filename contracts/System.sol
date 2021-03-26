pragma solidity 0.5.16;

contract System {

    address public governance;
    address public controller;
    address public positionManager;

    modifier onlyGovernance() {
        require(msg.sender == governance);
        _;
    }

    function setGovernance(address _governance) public onlyGovernance {
        governance = _governance;
    }

    function setController(address _controller) public onlyGovernance {
        controller = _controller;
    }

    function setPositionManager(address _positionManager) public onlyGovernance {
        positionManager = _positionManager;
    }

    function isGovernance(address account) public view returns (bool) {
        return account == governance;
    }

    function isController(address account) public view returns (bool) {
        return account == controller;
    }

    function isPositionManager(address account) public view returns (bool) {
        return account == positionManager;
    }

}