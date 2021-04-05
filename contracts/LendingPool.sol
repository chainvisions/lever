pragma solidity 0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/ILendingPoolToken.sol";
import "./Controllable.sol";
import "./LendingPoolToken.sol";

/// @title Lever Lending Pool
/// @author Chainvisions
/// @notice Lending pool for Lever Protocol. Allowing for leveraged
/// positions to borrow funds.

contract LendingPool is ILendingPool, ReentrancyGuard, Controllable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Pool {
        ILendingPoolToken lToken;   // Lending pool token to mint on deposit.
        uint256 maxBorrowingPower;  // Max percentage of collateral that may be borrowed against.
        mapping(address => uint256) collateralSupplied;     // Collateral supplied to the pool.
        mapping(address => uint256) debt;   // Lending pool debt from the specified address.
    }

    uint256 constant basisPoint = 1000; // 1000 basis points for percentages.
    mapping(address => Pool) public lendingToken;
    event Deposit(address indexed beneficiary, uint256 amount);

    modifier onlyGovernanceOrController {
        require(msg.sender == governance() || msg.sender == controller(), "LendingPool: Caller must be Governance or Controller");
        _;
    }

    constructor(address _system) public Controllable(_system) {}

    function deposit(address _token, uint256 _amount) public nonReentrant {
        _deposit(_amount, _token, msg.sender, msg.sender);
    }

    function depositFor(address _token, uint256 _amount, address _to) public nonReentrant {
        _deposit(_amount, _token, msg.sender, _to);
    }

    function _deposit(uint256 _amount, address _token, address _from, address _to) internal {
        Pool storage pool = lendingToken[_token];
        require(_amount > 0, "LendingPool: Cannot deposit 0");
        require(_to != address(0), "LendingPool: Must send to a valid address");

        uint256 toMint = pool.lToken.totalSupply() == 0
            ? _amount
            : _amount.mul(pool.lToken.totalSupply()).div(tokenBalance(_token));
        pool.lToken.mint(_to, toMint);
        IERC20(_token).safeTransferFrom(_from, address(this), _amount);
        emit Deposit(_to, _amount);
    }

    function withdraw(address _token, uint256 _amount) external {
        Pool storage pool = lendingToken[_token];
        require(pool.lToken.totalSupply() > 0, "LendingPool: This pool has no tokens");
        require(_amount > 0, "LendingPool: Cannot withdraw 0");
        pool.lToken.burn(msg.sender, _amount);
        uint256 amountToWithdraw = _amount.mul(lTokenPrice(_token));
        IERC20(_token).safeTransfer(msg.sender, amountToWithdraw);
    }

    function borrow(address _token, address _collateral, uint256 _amount) public {
        Pool storage pool = lendingToken[_collateral];
        Pool storage borrowPool = lendingToken[_token];
        uint256 collateralBorrowingPower = pool.collateralSupplied[msg.sender].mul(borrowPool.maxBorrowingPower).div(basisPoint);
        require(_amount <= collateralBorrowingPower, "LendingPool: Cannot borrow over your borrowing power");
        borrowPool.debt[msg.sender] = borrowPool.debt[msg.sender].add(_amount);
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    function addToken(address _token) public onlyGovernanceOrController {
        Pool storage pool = lendingToken[_token];
        require(address(pool.lToken) == address(0), "LendingPool: Pool already exists");
        LendingPoolToken poolToken = new LendingPoolToken(
            string(abi.encodePacked("Lever Lending ", ERC20Detailed(_token).symbol())), 
            string(abi.encodePacked("l", ERC20Detailed(_token).symbol()))
        );
        pool.lToken = ILendingPoolToken(address(poolToken));
    }

    function tokenBalance(address _token) public view returns (uint256) {
        IERC20(_token).balanceOf(address(this));
    }    

    function lTokenPrice(address _token) public view returns (uint256) {
        Pool storage pool = lendingToken[_token];
        return pool.lToken.totalSupply().mul(1e18).div(IERC20(_token).balanceOf(address(this)));
    }

}