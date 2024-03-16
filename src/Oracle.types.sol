// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error CommitTooEarly();
error RevealTooEarly();
error InvalidReveal();

interface IOracle {
    function decimals() external pure returns (uint8);

    function epochLength() external pure returns (uint32);

    function getPrice() external view returns (uint256);

    function getActiveEpoch() external view returns (uint256);

    function canCommit() external view returns (bool);

    function canReveal() external view returns (bool);

    function commit(bytes32 hashValue) external;

    function reveal(uint256 secret, uint256 price) external;

    function register() external;

    function unRegister() external;
}
