pragma solidity 0.5.16;

/// @title Leveraged Position Liquidator
/// @author Chainvisions
/// @notice contract that uses flashloans to liquidate a specified position.

/*
* --- Liquidation Flow ---
* 1. The contract calls the PositionManager and determines if the collateral can be liquidated.
* 2. The contract creates a flashloan through multiplier.finance and it liquidates the position's collateral.
* 3. It sends 50% of the liquidated collateral to the Controller as protocol profit and the rest to the liquidator.
*/

contract PositionLiquidator {
    function liquidate(address _position) public {
        // doSomething()
    }
}