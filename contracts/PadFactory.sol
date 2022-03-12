// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PadFactory is Ownable {
    mapping(address => bool) public isModel;

    /* ========== RESTRICTED FUNCTIONS ========== */
    function addModel(address _model) public onlyOwner {
        isModel[_model] = true;
    }
    
    function delModel(address _model) public onlyOwner {
        isModel[_model] = false;
    }
}