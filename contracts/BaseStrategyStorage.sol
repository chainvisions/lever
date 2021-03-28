pragma solidity 0.5.16;

import "@openzeppelin/upgrades/contracts/Initializable.sol";


contract BaseStrategyStorage {
    bytes32 internal constant _NEXT_IMPLEMENTATION_SLOT = 0x29f7fcd4fe2517c1963807a1ec27b0e45e67c60a874d5eeac7a0b1ab1bb84447;
    bytes32 internal constant _NEXT_IMPLEMENTATION_TIMESTAMP_SLOT = 0x414c5263b05428f1be1bfa98e25407cc78dd031d0d3cd2a2e3d63b488804f22e;
    bytes32 internal constant _NEXT_IMPLEMENTATION_DELAY_SLOT = 0x82b330ca72bcd6db11a26f10ce47ebcfe574a9c646bccbc6f1cd4478eae16b31;

    constructor() public {
        assert(_NEXT_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.nextImplementation")) - 1));
        assert(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.nextImplementationTimestamp")) - 1));
        assert(_NEXT_IMPLEMENTATION_DELAY_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.nextImplementationDelay")) - 1));
    }

    function _setNextImplementation(address _address) internal {
        setAddress(_NEXT_IMPLEMENTATION_SLOT, _address);
    }

    function nextImplementation() public view returns (address) {
        return getAddress(_NEXT_IMPLEMENTATION_SLOT);
    }

    function _setNextImplementationTimestamp(uint256 _value) internal {
        setUint256(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT, _value);
    }

    function nextImplementationTimestamp() public view returns (uint256) {
        return getUint256(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT);
    }

    function _setNextImplementationDelay(uint256 _value) internal {
        setUint256(_NEXT_IMPLEMENTATION_DELAY_SLOT, _value);
    }

    function nextImplementationDelay() public view returns (uint256) {
        return getUint256(_NEXT_IMPLEMENTATION_DELAY_SLOT);
    }

    function setAddress(bytes32 slot, address _address) internal {
        assembly {
            sstore(slot, _address)
        }
    }

    function setUint256(bytes32 slot, uint256 _value) internal {
        assembly {
            sstore(slot, _value)
        }
    } 

    function getAddress(bytes32 slot) internal view returns (address str) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            str := sload(slot)
        }
    }

    function getUint256(bytes32 slot) internal view returns (uint256 str) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            str := sload(slot)
        }
    }

}