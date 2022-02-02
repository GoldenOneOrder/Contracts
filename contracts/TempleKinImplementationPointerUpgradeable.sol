// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../contracts/ITempleKin.sol";

abstract contract TempleKinImplementationPointerUpgradeable is OwnableUpgradeable {
    ITempleKin internal temple;

    event UpdateTempleKin(
        address indexed oldImplementation,
        address indexed newImplementation
    );

    modifier onlyTempleKin() {
        require(
            address(temple) != address(0),
            "Implementations: TempleKin is not set"
        );
        address sender = _msgSender();
        require(
            sender == address(temple),
            "Implementations: Not TempleKin"
        );
        _;
    }

    function getTempleKinImplementation() public view returns (address) {
        return address(temple);
    }

    function changeTempleKinImplementation(address newImplementation)
        public
        virtual
        onlyOwner
    {
        address oldImplementation = address(temple);
        require(
            AddressUpgradeable.isContract(newImplementation) ||
                newImplementation == address(0),
            "TempleKin: You can only set 0x0 or a contract address as a new implementation"
        );
        temple = ITempleKin(newImplementation);
        emit UpdateTempleKin(oldImplementation, newImplementation);
    }

    uint256[49] private __gap;
}