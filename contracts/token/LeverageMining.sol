pragma solidity 0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../interfaces/ILever.sol";
import "../Governable.sol";

/// @title Lever Protocol Leverage Mining
/// @author Chainvisions
/// @notice Smart contract for LVR farming and LVR Leverage Mining.

contract LeverageMining is Governable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many tokens deposited.
        uint256 rewards; // How many rewards that are pending.
    }

    struct PoolInfo {
        IERC20 stakeToken; // Token that is staked for rewards.
        uint256 rewardReserves; // Rewards to distribute.
        uint256 poolDuration; // How long the rewards will last for.
        uint256 rewardDelay; // How long until rewards are distributed after the pool creation.
        uint256 rewardsPerShare; // How many rewards per token staked in the pool.
    }

    // LVR token to distribute.
    ILever public lever;
    // Rewards to be distributed for bonus mining.
    uint256 public bonusMiningRewards = 10000e18; // 10k LVR
    // Rewards to be distributed for leverage mining.
    uint256 public leverageMiningRewards = 50000e18; // 50k LVR
    // How long each bonus mining pool lasts
    uint256 public bonusPoolDuration = 14 days;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Greylist for allowing greylisted contracts to interact with bonus mining.
    mapping(address => bool) greylist;

    // We introduce a mechanism to prevent vampire farming on LVR bonus mining.
    modifier vampireDefense {
        require(msg.sender == tx.origin || greylist[msg.sender], "LeverageMining: Vampire defenses active");
        _;
    }

    // Updates a bonus pool.
    modifier updatePool(uint256 _pid) {
        PoolInfo storage pool = poolInfo[_pid];
        pool.rewardsPerShare = reward
        _;
    }

    constructor(address _system, ILever _lever) public Governable(_system) {
        lever = _lever;
    }

    /* ========== BONUS MINING ========== */

    // Add a new bonus mining pool.
    function addPool(IERC20 _stakeToken, uint256 _rewardAllocation, uint256 _rewardDelay) public onlyGovernance {
        require(_rewardAllocation <= bonusMiningRewards, "LeverageMining: Bonus rewards cannot go over allocation");
        bonusMiningRewards = bonusMiningRewards.sub(_rewardAllocation);
        lever.mint(address(this), _rewardAllocation);
        poolInfo.push(
            PoolInfo({
                stakeToken: _stakeToken,
                rewardReserves: _rewardAllocation,
                poolDuration: now.add(bonusPoolDuration),
                rewardDelay: _rewardDelay,
                rewardsPerShare: 0
            })
        );
    }

    // Update the allocation of a bonus mining pool.
    function updateAllocation(uint256 _pid, uint256 _rewardAllocation) public onlyGovernance {
        PoolInfo storage pool = poolInfo[_pid];
        require(now > pool.poolDuration, "LeverageMining: Pool must expire before it can be allocated more rewards");
        require(_rewardAllocation <= bonusMiningRewards, "LeverageMining: Bonus rewards cannot go over allocation");
        bonusMiningRewards = bonusMiningRewards.sub(_rewardAllocation);
        lever.mint(address(this), _rewardAllocation);
        pool.poolDuration = now.add(bonusPoolDuration);
        pool.rewardReserves = _rewardAllocation;
    }

    // Stake into a bonus reward pool.
    function stake(uint256 _pid, uint256 _amount) public vampireDefense updatePool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(pool.poolDuration > now, "LeverageMining: Pool has expired");
        pool.stakeToken.safeTransferFrom(msg.sender, address(this), _amount);
        user.amount = user.amount.add(_amount);
    }

    // Withdraw from a bonus reward pool.
    function withdraw(uint256 _pid, uint256 _amount) public vampireDefense updatePool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(_amount <= user.amount, "LeverageMining: Cannot withdraw more than the deposited amount");
        user.amount = user.amount.sub(_amount);
    }

    // Add an address to the greylist.
    function addToGreylist(address _account) public onlyGovernance {
        greylist[_account] = true;
    }

    // Remove an address from the greylist.
    function removeFromGreylist(address _account) public onlyGovernance {
        greylist[_account] = false;
    }

    /* ========== LEVERAGE MINING ========== */


}