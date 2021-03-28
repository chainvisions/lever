pragma solidity 0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/IController.sol";
import "./interfaces/IPositionManager.sol";
import "./Manageable.sol";
import "./Position.sol";

contract PositionManager is IPositionManager, Manageable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct PositionInfo {
        address positionAddress;
    }

    // Collateral for positions.
    address public collateral;
    // Principal for investments made
    // by position strategies.
    address public principal;
    // Information on all positions.
    PositionInfo[] public positionInfo;
    event PositionOpened(uint256 indexed id, address indexed position);

    constructor(address _system, address _collateral, address _principal) public Manageable(_system) {
        collateral = _collateral;
        principal = _principal;
    }

    function openPosition(address _strategy) public {
        require(IController(controller()).strategyApproved(_strategy), "PositionManager: Unauthorized strategy");
        Position position = new Position(address(system), _strategy);
        positionInfo.push(
            PositionInfo({
                positionAddress: address(position)
            })
        );
        emit PositionOpened(positionInfo.length.sub(1), positionInfo[positionInfo.length.sub(1)].positionAddress);
    }

    function salvage(address _token, uint256 _amount) public onlyGovernance {
        IERC20(_token).safeTransfer(governance(), _amount);
    }

}