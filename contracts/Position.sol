pragma solidity 0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/IPosition.sol";
import "./interfaces/IController.sol";
import "./Manageable.sol";

/// @title Leveraged Position
/// @author Chainvisions
/// @notice A leveraged yield farming position.

contract Position is IPosition, Manageable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Collateral for borrowing
    address public collateral;
    // Principal that is borrowed.
    address public principal;
    // Strategy for yield generation.
    address public strategy;
    // Owner of the position.
    address public owner;
    // How much collateral to utilize.
    uint256 public maxUtilization;
    // Health factor where debt is automatically repayed.
    uint256 public unsafeHeathFactor;
    // Percentage to liquidate to repay the debt.
    uint256 public liquidationPct;
    // Name to display on BSCScan.
    string public name = "Lever Protocol Leveraged Position";
    // Trusted managers for managing the position.
    mapping(address => bool) public managers;

    modifier restricted {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerOrManager {
        require(msg.sender == owner || managers[msg.sender]);
        _;
    }

    constructor(address _system, address _strategy) public Manageable(_system) {
        collateral = IController(controller()).collateral();
        principal = IController(controller()).principal();
        strategy = _strategy;
        owner = tx.origin;
        maxUtilization = 400; // 40%
        unsafeHeathFactor = 105e18; // TODO: Change this to something else
        liquidationPct = 100; // 10%
    }

    // Supplies the 
    function supplyCollateral(uint256 _amount) public restricted {
        _supplyCollateral(_amount);
    }

    function _supplyCollateral(uint256 _amount) internal {

    }

    function repayDebt(uint256 _amount) public {

    }

    function _repayDebt(uint256 _amount) internal {

    }

    function harvestAndCompound() public restricted {
        (bool success, bytes memory data) = strategy.delegatecall(
            abi.encodeWithSignature("harvest()")
        );

    }

    function manage() public onlyOwnerOrManager {
        harvestAndCompound();
        if(supplyHealthFactor() <= unsafeHeathFactor) {
            _repayDebt(100e18);
        }
    }

    // Liquidates the position back into the principal.
    function liquidatePosition() public restricted {

    }

    // Kills the position contract and sends all
    // funds to the position owner.
    function closePosition() public restricted {
        liquidatePosition();
    }

    // Allows for adding a trusted manager to
    // manage the position.
    function addManager(address _manager) public restricted {
        managers[_manager] = true;
    }
    
    // Allows for removing a manager.
    function removeManager(address _manager) public restricted {
        managers[_manager] = false;
    }

    // Transfers ownership of the Position.
    function transferPosition(address _newOwner) public restricted {
        owner = _newOwner;
    }

    // Allows for adjusting the risk tolerance of the position.
    function adjustUnsafeHealthFactor(uint256 _unsafeHealthFactor) public restricted {
        unsafeHeathFactor = _unsafeHealthFactor;
    }

    // Allows for adjusting how much of the position to liquidate to repay the debt.
    function adjustLiquidationPct(uint256 _liquidationPct) public restricted {
        liquidationPct = _liquidationPct;
    }

    // Allows for adjusting the max amount of collateral to utilize.
    function adjustMaxUtilization(uint256 _maxUtilization) public restricted {
        maxUtilization = _maxUtilization;
    }

    function salvage(address _token, uint256 _amount) public restricted {
        IERC20(_token).safeTransfer(owner, _amount);
    }

    // Current health factor of the collateral supplied.
    function supplyHealthFactor() public view returns (uint256) {

    }

}