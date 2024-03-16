// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error CommitTooEarly();
error RevealTooEarly();
error InvalidReveal();

interface IOracle {
    function decimals() external pure returns (uint8);

    function getPrice() external view returns (uint256);

    function commit(bytes32 hashValue) external;

    function canCommit() external returns (bool);

    function reveal(uint256 secret, uint256 price) external;
}
