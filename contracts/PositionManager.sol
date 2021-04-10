pragma solidity 0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/IPositionManager.sol";
import "./interfaces/IController.sol";
import "./interfaces/IPosition.sol";
import "./Controllable.sol";
import "./Position.sol";

contract PositionManager is IPositionManager, Controllable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct PositionInfo {
        address positionAddress;
    }

    // Information on all positions.
    PositionInfo[] public positionInfo;
    // List of positions created by the user. This allows
    // for the frontend to query all positions held.
    mapping(address => address[]) userPositions;
    mapping(address => bool) positions;
    event PositionOpened(uint256 indexed id, address indexed position);

    constructor(address _system) public Controllable(_system) {}

    function openPosition(address _strategy) public {
        require(IController(controller()).strategyApproved(_strategy), "PositionManager: Unauthorized strategy");
        Position position = new Position(address(system), _strategy);
        positionInfo.push(
            PositionInfo({
                positionAddress: address(position)
            })
        );
        positions[address(position)] = true;
        userPositions[msg.sender].push(address(position));
        emit PositionOpened(positionInfo.length.sub(1), positionInfo[positionInfo.length.sub(1)].positionAddress);
    }

    function salvage(address _token, uint256 _amount) public onlyGovernance {
        IERC20(_token).safeTransfer(governance(), _amount);
    }

    function positionAdjustable(address _position) public view returns (bool) {
        if(IPosition(_position).marketSnapshot() != IController(controller()).bullOrBear()) {
            return true;
        } else {
            return false;
        }
    }

}