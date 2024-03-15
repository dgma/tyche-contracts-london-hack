// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOracle {
    function decimals() external pure returns (uint8);

    function getPrice() external view returns (uint256);
}
