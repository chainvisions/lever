// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/// @title Lever Protocol Reward Gauge
/// @author Chainvisions
/// @notice Reward Gauge contract for LVR rewards.

contract RewardGauge is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public stakeToken;
    address public rewardToken;
    uint256 public constant DURATION = 7 days;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) public derivedBalances;
    uint256 private _totalSupply;
    uint256 public derivedSupply;

    event Deposit(address indexed staker, address indexed amount);

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if(_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid;
        }
    }

    constructor(address _stakeToken) public {
        stakeToken = IERC20(_stakeToken);
    }

    function stake(uint256 _amount) external {
        _stake(msg.sender, msg.sender, _amount);
    }

    function stakeFor(address _for, uint256 _amount) external {
        _stake(msg.sender, _for, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(_amount <= _balances[msg.sender], "RewardGauge: Cannot withdraw more than stake");
        _totalSupply = _totalSupply.sub(_amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        stakeToken.safeTransfer(msg.sender, _amount);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _account) external view returns (uint256) {
        return _balances[_account];
    }

    function getReward() public {
        // doSomething()
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if(_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply);
    }

    function exit() external {
        uint256 amount = _balances[msg.sender];
        _balances[msg.sender] = 0;
        stakeToken.safeTransfer(msg.sender, amount);
        getReward();
    }

    /// @notice Internal function for staking tokens into the gauge.
    /// @param _from Address to transfer tokens from.
    /// @param _for Address to credit with the stake.
    /// @param _amount Amount to stake.
    function _stake(address _from, address _for, uint256 _amount) internal nonReentrant {
        require(_amount > 0, "RewardGauge: Cannot deposit 0");
        _totalSupply = _totalSupply.add(_amount);
        _balances[_for] = _balances[_for].add(_amount);
        stakeToken.safeTransferFrom(_from, address(this), _amount);
        emit Deposit(_for, _amount);
    }

}