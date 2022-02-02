// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../contracts/IGradeTokensManager.sol";

abstract contract GradeTokensManagerImplementationPointerUpgradeable is OwnableUpgradeable {
    IGradeTokensManager internal gradeTokensManager;

    event UpdateGradeTokensManager(
        address indexed oldImplementation,
        address indexed newImplementation
    );

    modifier onlyCardsManager() {
        require(
            address(gradeTokensManager) != address(0),
            "Implementations: CardsManager is not set"
        );
        address sender = _msgSender();
        require(
            sender == address(gradeTokensManager),
            "Implementations: Not CardsManager"
        );
        _;
    }

    function getCardsManagerImplementation() public view returns (address) {
        return address(gradeTokensManager);
    }

    function changeCardsManagerImplementation(address newImplementation)
        public
        virtual
        onlyOwner
    {
        address oldImplementation = address(gradeTokensManager);
        require(
            AddressUpgradeable.isContract(newImplementation) ||
                newImplementation == address(0),
            "CardsManager: You can only set 0x0 or a contract address as a new implementation"
        );
        gradeTokensManager = IGradeTokensManager(newImplementation);
        emit UpdateGradeTokensManager(oldImplementation, newImplementation);
    }

    uint256[49] private __gap;
}