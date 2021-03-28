pragma solidity 0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/ILever.sol";

contract LeverageMining is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewards;
    }

    struct PoolInfo {
        IERC20 stakeToken;
        uint256 rewardReserves;
        uint256 poolDuration;
        uint256 rewardsPerShare;
    }

    ILever public lever;
    uint256 public bonusMiningRewards = 10000e18; // 10k LVR
    uint256 public leverageMiningRewards = 50000e18; // 50k LVR
    uint256 public bonusPoolDuration = 14 days;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => bool) greylist;

    // Prevent yield optimizers from farming bonus pools.
    modifier vampireDefense {
        require(msg.sender == tx.origin || greylist[msg.sender], "LeverageMining: Vampire defenses active");
        _;
    }

    constructor() public {}

    /* ========== BONUS REWARDS ========== */

    function addPool(IERC20 _stakeToken, uint256 _rewardAllocation) public onlyOwner {
        require(_rewardAllocation <= bonusMiningRewards, "LeverageMining: Bonus rewards cannot go over allocation");
        lever.mint(address(this), _rewardAllocation);
        poolInfo.push(
            PoolInfo({
                stakeToken: _stakeToken,
                rewardReserves: _rewardAllocation,
                poolDuration: now.add(bonusPoolDuration),
                rewardsPerShare: 0
            })
        );
    }

    function stake(uint256 _pid, uint256 _amount) public vampireDefense {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.stakeToken.safeTransferFrom(msg.sender, address(this), _amount);
        user.amount = user.amount.add(_amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public vampireDefense {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(_amount <= user.amount, "LeverageMining: Cannot withdraw more than the deposited amount");
        user.amount = user.amount.sub(_amount);
    }

    function addToGreylist(address _account) public onlyOwner {
        greylist[_account] = true;
    }

    function removeFromGreylist(address _account) public onlyOwner {
        greylist[_account] = false;
    }

    /* ========== LEVERAGE MINING ========== */


}