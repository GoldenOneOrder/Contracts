// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../contracts/OwnerRecovery.sol";
import "../contracts/LiquidityPoolManagerImplementationPointer.sol";
import "../contracts/WalletObserverImplementationPointer.sol";

contract TempleKin is
    ERC20,
    ERC20Burnable,
    Ownable,
    OwnerRecovery,
    LiquidityPoolManagerImplementationPointer,
    WalletObserverImplementationPointer
{
    address public immutable gradeTokensManager;

    modifier onlyGradeTokensManager() {
        address sender = _msgSender();
        require(
            sender == address(gradeTokensManager),
            "Implementations: Not GradeTokensManager"
        );
        _;
    }

    constructor(address _gradeTokensManager) ERC20("Temple Kin", "KIN") {
        require(
            _gradeTokensManager != address(0),
            "Implementations: GradeTokensManager is not set"
        );
        gradeTokensManager = _gradeTokensManager;
        _mint(owner(), 42_000_000_000 * (10**18));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (address(walletObserver) != address(0)) {
            walletObserver.beforeTokenTransfer(_msgSender(), from, to, amount);
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._afterTokenTransfer(from, to, amount);
        if (address(liquidityPoolManager) != address(0)) {
            liquidityPoolManager.afterTokenTransfer(_msgSender());
        }
    }

    function accountBurn(address account, uint256 amount)
        external
        onlyGradeTokensManager
    {
        // Note: _burn will call _beforeTokenTransfer which will ensure no denied addresses can create cargos
        // effectively protecting GradeTokensManager from suspicious addresses
        super._burn(account, amount);
    }

    function accountReward(address account, uint256 amount)
        external
        onlyGradeTokensManager
    {
        require(
            address(liquidityPoolManager) != account,
            "TempleKin: Use liquidityReward to reward liquidity"
        );
        super._mint(account, amount);
    }

    function liquidityReward(uint256 amount) external onlyGradeTokensManager {
        require(
            address(liquidityPoolManager) != address(0),
            "TempleKin: LiquidityPoolManager is not set"
        );
        super._mint(address(liquidityPoolManager), amount);
    }
}