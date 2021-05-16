pragma solidity 0.5.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/ILever.sol";
import "../Governable.sol";
import "./RewardGauge.sol";

/// @title Lever Gauge Controller
/// @author Chainvisions
/// @notice Controller contract for Lever Reward Gauges.
contract GaugeController is Governable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Reward Distribution
    ILever public lever;
    address[] internal tokens;
    mapping(address => address) public gauges;
    mapping(address => address) public rewardWeight;

    // Emission Schedule
    uint256 public leverPerBlock;
    uint256 public lastMintAt;

    event TokensEmitted(uint256 indexed timestamp, uint256 indexed tokens);
    event GaugeAdded(
        address indexed timestamp, 
        address indexed token, 
        address indexed gaugeAddress
    );

    constructor(address _system) public Governable(_system) {}

    /// @notice Distributes LVR to all of the gauges.
    function distributeRewards() external {
        emitTokens();
        uint256 balance = IERC20(address(lever)).balanceOf(address(this));
    }

    /// @notice Deploys a new reward gauge contract.
    /// @param _token Token to create a gauge of.
    function addGauge(address _token) external onlyGovernance {
        require(gauges[_token] == address(0), "GaugeController: Reward gauge already exists");
        gauges[_token] = address(new RewardGauge(_token));
        tokens.push(_token);
        emit GaugeAdded(block.timestamp, _token, gauges[_token]);
    }

    /// @notice Emits new LVR tokens.
    function emitTokens() public {
        uint256 blocksToMintFor = block.number.sub(lastMintAt);
        uint256 lvrToMint = blocksToMintFor.mul(leverPerBlock);
        lever.mint(address(this), lvrToMint);
        emit TokensEmitted(block.timestamp, lvrToMint);
    }

}