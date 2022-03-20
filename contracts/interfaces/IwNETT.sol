// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

interface IwNETT {
    /**
     * @dev Destroys `amount` tokens from `from`.
     *
     * See {ERC20-_burn}.
     */
    function burnFrom(address from, uint256 amount) external;
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
}