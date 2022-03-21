// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IPrimary {
    function initialize(
        address _issuer,
        address _issuedToken,
        address _paymentToken,
        uint256 _issuedTokenAmount,
        uint256 _price,
        uint256 _maxAllocPerUser,
        uint256 _depositStartTime,
        uint256 _depositDuration,
        uint256 _launchTime,
        uint256 _decimals
    ) external;
}