pragma solidity 0.5.16;

import "@openzeppelin/upgrades/contracts/upgradeability/BaseUpgradeabilityProxy.sol";
import "./interfaces/IUpgradeSource.sol";

/// @title Lever Strategy Proxy
/// @notice Proxy for Lever strategies

contract StrategyProxy is BaseUpgradeabilityProxy {
    constructor(address _implementation) public {
        _setImplementation(_implementation);
    }

  /**
  * The main logic. If the timer has elapsed and there is a schedule upgrade,
  * the governance can upgrade the strategy
  */
  function upgrade() external {
    (bool should, address newImplementation) = IUpgradeSource(address(this)).shouldUpgrade();
    require(should, "Strategy Proxy: Upgrade not scheduled");
    _upgradeTo(newImplementation);

    // The finalization needs to be executed on itself to update the storage of this proxy
    // it also needs to be invoked by the governance, not by address(this), so delegatecall is needed
    (bool success, bytes memory result) = address(this).delegatecall(
      abi.encodeWithSignature("finalizeUpgrade()")
    );

    require(success, "Strategy Proxy: Issue when finalizing the upgrade");
  }

    function implementation() external view returns (address) {
        return _implementation();
    }

}