// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/ILever.sol";
import "../Governable.sol";

/// @title Lever Protocol Leverage Mining
/// @author Chainvisions
/// @notice Smart contract for LVR farming and LVR Leverage Mining.

contract LeverageMining is Governable {
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

    struct Epoch {
        uint256 rewards;
        uint256 epochStartTime;
        uint256 epochEndTime;
    }

    // LVR token to distribute.
    ILever public lever;
    // Rewards to be distributed for bonus mining.
    uint256 public bonusMiningRewards = 10000e18; // 10k LVR
    // Rewards to be distributed for leverage mining.
    uint256 public leverageMiningRewards = 50000e18; // 50k LVR
    // How long each bonus mining pool lasts
    uint256 public bonusPoolDuration = 14 days;
    // How many rewards can be reclaimed by governance.
    uint256 public governanceClaimableRewards;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Greylist for allowing greylisted contracts to interact with bonus mining.
    mapping(address => bool) greylist;

    // We introduce a mechanism to prevent vampire farming on LVR bonus mining.
    modifier vampireDefense {
        require(msg.sender == tx.origin || greylist[msg.sender], "LeverageMining: Vampire defenses active");
        _;
    }

    modifier contractHasMinter {
        require(lever.isMinter(address(this)), "LeverageMining: Contract is not added as a minter");
        _;
    }

    // Updates a bonus pool.
    modifier updatePool(uint256 _pid) {
        PoolInfo storage pool = poolInfo[_pid];
        pool.rewardsPerShare = 0;
        _;
    }

    constructor(address _system, ILever _lever) Governable(_system) {
        lever = _lever;
    }

    /* ========== BONUS MINING ========== */

    // Add a new bonus mining pool.
    function addPool(IERC20 _stakeToken, uint256 _rewardAllocation, uint256 _rewardDelay) public onlyGovernance contractHasMinter {
        require(_rewardAllocation <= bonusMiningRewards, "LeverageMining: Bonus rewards cannot go over allocation");
        bonusMiningRewards = bonusMiningRewards - _rewardAllocation;
        lever.mint(address(this), _rewardAllocation);
        poolInfo.push(
            PoolInfo({
                stakeToken: _stakeToken,
                rewardReserves: _rewardAllocation,
                poolDuration: block.timestamp + bonusPoolDuration,
                rewardDelay: _rewardDelay,
                rewardsPerShare: 0
            })
        );
    }

    // Update the allocation of a bonus mining pool.
    function updateAllocation(uint256 _pid, uint256 _rewardAllocation) public onlyGovernance contractHasMinter {
        PoolInfo storage pool = poolInfo[_pid];
        require(block.timestamp > pool.poolDuration, "LeverageMining: Pool must expire before it can be allocated more rewards");
        require(_rewardAllocation <= bonusMiningRewards, "LeverageMining: Bonus rewards cannot go over allocation");
        bonusMiningRewards = bonusMiningRewards - _rewardAllocation;
        lever.mint(address(this), _rewardAllocation);
        pool.poolDuration = block.timestamp + bonusPoolDuration;
        pool.rewardReserves = _rewardAllocation;
    }

    // Stake into a bonus reward pool.
    function stake(uint256 _pid, uint256 _amount) public vampireDefense updatePool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(pool.poolDuration > block.timestamp, "LeverageMining: Pool has expired");
        pool.stakeToken.safeTransferFrom(msg.sender, address(this), _amount);
        user.amount = user.amount + _amount;
    }

    // Withdraw from a bonus reward pool.
    function withdraw(uint256 _pid, uint256 _amount) public vampireDefense updatePool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(_amount <= user.amount, "LeverageMining: Cannot withdraw more than the deposited amount");
        user.amount = user.amount - _amount;
    }

    // Withdraw from the contract and forget your rewards.
    function exit(uint256 _pid) public vampireDefense {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.stakeToken.safeTransfer(msg.sender, user.amount);
        governanceClaimableRewards = governanceClaimableRewards + user.rewards;
        user.amount = 0;
        user.rewards = 0;
    }

    /* ========== LEVERAGE MINING ========== */

    /* ========== GOVERNANCE FUNCTIONS ========== */

    // Claim any rewards that were forgotten.
    function performClaim() public onlyGovernance {
        uint256 rewards = governanceClaimableRewards;
        governanceClaimableRewards = 0;
        IERC20(address(lever)).safeTransfer(governance(), rewards);
    }

    // TODO: Loop through each pool and make sure `_token` is not a pool token.
    // Allows for recovering any arbitrary ERC20 token sent to the contract.
    function recoverERC20(address _token, uint256 _amount) public onlyGovernance {
        IERC20(_token).safeTransfer(governance(), _amount);
    }

    // Add an address to the greylist.
    function addToGreylist(address _account) public onlyGovernance {
        greylist[_account] = true;
    }

    // Remove an address from the greylist.
    function removeFromGreylist(address _account) public onlyGovernance {
        greylist[_account] = false;
    }

    // Burn the minting key of the contract.
    function burnMinter() public onlyGovernance {
        require(bonusMiningRewards == 0 && leverageMiningRewards == 0, "LeverageMining: The contract still has rewards");
        lever.renounceMinter();
    }

}