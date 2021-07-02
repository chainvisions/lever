pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IPosition.sol";
import "./interfaces/IController.sol";
import "./Manageable.sol";

/// @title Leveraged Position
/// @author Chainvisions
/// @notice A leveraged yield farming position.

contract Position is IPosition, Manageable {
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
    // Overrides maxUtilization and uses the most collateral possible.
    // Note: Utilizing the max amount of collateral brings higher risks of
    // having your position liquidated.
    bool public utilizeMax;
    // Health factor where debt is automatically repayed.
    uint256 public unsafeHeathFactor;
    // Percentage to liquidate to repay the debt.
    uint256 public liquidationPct;
    // Snapshot of what the current market is.
    bool public marketSnapshot;
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

    constructor(address _system, address _strategy) Manageable(_system) {
        require(msg.sender == positionManager(), "Position: Creator is not PositionManager");
        collateral = IController(controller()).collateral();
        principal = IController(controller()).principal();
        marketSnapshot = IController(controller()).bullOrBear();
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
        require(success, "Position: Harvest failed");
    }

    function manage() public onlyOwnerOrManager {
        harvestAndCompound();
        if(supplyHealthFactor() <= unsafeHeathFactor) {
            uint256 amountToLiquidate = (investment() * liquidationPct) / 1000;
            _liquidateAmount(amountToLiquidate);
            _repayDebt(100e18);
        }
    }

    function _liquidateAmount(uint256 _amount) internal {
        (bool success, bytes memory data) = strategy.delegatecall(
            abi.encodeWithSignature("liquidateAmount(uint256 _amount)", _amount)
        );
        require(success, "Position: Liquidation failed");
    }

    function investment() public view returns (uint256) {
        (bool success, bytes memory data) = strategy.staticcall(
            abi.encodeWithSignature("investment()")
        );
        require(success, "Position: Fetching investment failed");
        return abi.decode(data, (uint256));
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