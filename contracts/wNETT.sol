// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPadFactory {
    function isModel(address) external view returns (bool);
}

/// @title WholeFood NETT - wNETT
/// @author Netswap
/// @notice Infinite supply, but burned to join a launch event
contract wNETT is ERC20("WholeFood NETT", "wNETT"), Ownable {
    IPadFactory public padFactory;

    /// @dev Creates `_amount` token to `_to`. Must only be called by the owner (wNETTStaking)
    /// @param _to The address that will receive the mint
    /// @param _amount The amount to be minted
    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    /// @dev Destroys `_amount` tokens from `_from`. Callable only by a event model
    /// this doesn't need any approval in order to avoid double approval before entering each launch event
    /// @param _from The address that will burn tokens
    /// @param _amount The amount to be burned
    function burnFrom(address _from, uint256 _amount)
        external
        onlyModel
    {
        _burn(_from, _amount);
    }

    /// @dev Hook that is called before any transfer of tokens. This includes
    /// minting and burning
    /// @param _from The address that will transfer the tokens
    /// @param _to The address that will receive the tokens
    /// @param _amount The amount of token to send
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override {
        require(
            _from == address(0) || _to == address(0) || _from == owner(),
            "wNETT: can't send token"
        );
        super._beforeTokenTransfer(_from, _to, _amount);
    }

    /// @notice Modifier which checks if msg.sender is a model contract
    modifier onlyModel() {
        require(padFactory.isModel(msg.sender), "caller is not a model");
        _;
    }

    /* ========== RESTRICTED FUNCTIONS ========== */
    function setPadFactory(IPadFactory _padFactory) public onlyOwner {
        padFactory = _padFactory;
    }
}