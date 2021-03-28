pragma solidity 0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/IController.sol";
import "./Manageable.sol";

contract Controller is IController, Manageable {
    using SafeERC20 for IERC20;

    address public feeBeneficiary;
    uint256 performanceFeeNumerator;
    uint256 performanceFeeDenominator;
    mapping(address => bool) public strategies;
    event FeesCollected(address indexed token, uint256 indexed fees);

    constructor(address _system) public Manageable(_system) {
        feeBeneficiary = governance();
    }

    function addStrategy(address _strategy) public onlyGovernance {
        strategies[_strategy] = true;
    }

    function removeStrategy(address _strategy) public onlyGovernance {
        strategies[_strategy] = false;
    }

    function collectFees(address _feeToken, uint256 _fee) external {
        IERC20(_feeToken).safeTransferFrom(msg.sender, feeBeneficiary, _fee);
        emit FeesCollected(_feeToken, _fee);
    }

    function strategyApproved(address _strategy) public view returns (bool) {
        return strategies[_strategy];
    }

}