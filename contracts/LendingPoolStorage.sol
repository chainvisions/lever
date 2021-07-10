// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

/// @title Lending Pool Storage
/// @author Chainvisions
/// @dev Storage for lending pool variables.

contract LendingPoolStorage {
    mapping(bytes32 => uint256) uint256Storage;
    mapping(bytes32 => address) addressStorage;
    mapping(bytes32 => bool) boolStorage;
    
    function _setUnderlying(address _address) internal {
        _setAddress("underlying", _address);
    }

    /// @dev Underlying token of the pool.
    function underlying() public view returns (address) {
        return _getAddress("underlying");
    }

    function _setVault(address _address) internal {
        _setAddress("vault", _address);
    }

    /// @dev Vault to deposit capital in.
    function vault() public view returns (address) {
        return _getAddress("vault");
    }

    function _setEfficiencyNumerator(uint256 _value) internal {
        _setUint256("efficiencyNumerator", _value);
    }

    /// @dev Percentage of deposits to put to work.
    function efficiencyNumerator() public view returns (uint256) {
        return _getUint256("efficiencyNumerator");
    }

    function _setSafeUtilization(uint256 _value) internal {
        _setUint256("safeUtilization", _value);
    }

    /// @dev Safe percentage of utilization for capital efficiency.
    function safeUtilization() public view returns (uint256) {
        return _getUint256("safeUtilization");
    }

    function _setGuarded(bool _value) internal {
        _setBool("guarded", _value);
    }

    /// @dev Guarded launch.
    function guarded() public view returns (bool) {
        return _getBool("guarded");
    }

    /// @dev Sets a uint256 in the storage.
    /// @param _key The key to store the value under.
    /// @param _value The value to store.
    function _setUint256(string memory _key, uint256 _value) internal {
        uint256Storage[keccak256(abi.encodePacked(_key))] = _value;
    }

    /// @dev Gets a uint256 from the storage.
    /// @param _key The key to retrieve the value from.
    function _getUint256(string memory _key) internal view returns (uint256) {
        return uint256Storage[keccak256(abi.encodePacked(_key))];
    }

    /// @dev Sets an address in the storage.
    /// @param _key The key to store the value under.
    /// @param _value The value to store.
    function _setAddress(string memory _key, address _value) internal {
        addressStorage[keccak256(abi.encodePacked(_key))] = _value;
    }

    /// @dev Gets an address from the storage.
    /// @param _key The key to retrieve the value from.
    function _getAddress(string memory _key) internal view returns (address) {
        return addressStorage[keccak256(abi.encodePacked(_key))];
    }

    /// @dev Sets a bool in the storage.
    /// @param _key The key to store the value under.
    /// @param _value The value to store.
    function _setBool(string memory _key, bool _value) internal {
        boolStorage[keccak256(abi.encodePacked(_key))] = _value;
    }

    /// @dev Gets a bool from the storage.
    /// @param _key The key to retrieve the value from.
    function _getBool(string memory _key) internal view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked(_key))];
    }
}