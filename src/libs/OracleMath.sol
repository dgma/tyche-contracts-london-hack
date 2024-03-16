// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library OracleMath {
    function roundFloor(uint256 value, uint256 denominator) public pure returns (uint256) {
        return value - value % denominator;
    }

    function floorDiv(uint256 value, uint256 denominator) external pure returns (uint256) {
        return roundFloor(value, denominator) / denominator;
    }

    function ceilDiv(uint256 value, uint256 denominator) external pure returns (uint256) {
        uint256 tail = value % denominator;
        if (tail == 0) {
            return value / denominator;
        }
        return (roundFloor(value, denominator) + denominator) / denominator;
    }
}
