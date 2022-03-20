
// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

interface IPadFactory {
    struct Multiplier {
        uint256 multiplier10;
        uint256 multiplier15;
        uint256 multiplier20;
        uint256 multiplier25;
        uint256 multiplier50;
        uint256 multiplier100;
    }
    function wNETT() external view returns (address);
    function USDPerWNETT() external view returns (uint256);
    function feeCollector() external view returns (address);
    function multiplierFeeRate(uint256) external view returns (uint256);
    function multiplier() external view returns (Multiplier memory);
}