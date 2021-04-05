pragma solidity 0.5.16;

import "./interfaces/multiplier/ILendingPoolAddressesProvider.sol";
import "./interfaces/multiplier/ILendingPool.sol";
import "./flashloan/FlashloanReceiverBase.sol";

/// @title Leveraged Position Liquidator
/// @author Chainvisions
/// @notice contract that uses flashloans to liquidate a specified position.

/*
* --- Liquidation Flow ---
* 1. The contract calls the PositionManager and determines if the collateral can be liquidated.
* 2. The contract creates a flashloan through multiplier.finance and it liquidates the position's collateral.
* 3. It sends 50% of the liquidated collateral to the Controller as protocol profit and the rest to the liquidator.
*/

contract PositionLiquidator is FlashloanReceiverBase {

    address public constant busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    constructor(ILendingPoolAddressesProvider _addressesProvider) public FlashloanReceiverBase(_addressesProvider) {

    }

    function liquidate(address _position) public {
        // TODO: Get the amount needed for liquidation.
        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        lendingPool.flashLoan(address(this), busd, 10000e18, "");
    }
}