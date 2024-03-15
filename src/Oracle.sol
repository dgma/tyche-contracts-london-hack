// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IOracle} from "src/Oracle.types.sol";

error TooEarly();

contract Oracle is IOracle {
    using Math for uint256;

    mapping(address => bytes32) private hashValues;

    function _convert(uint256 value) private pure returns (uint256) {
        return value * 10 ** decimals();
    }

    function decimals() public pure returns (uint8) {
        return 8;
    }

    function getPrice() external pure returns (uint256) {
        return _convert(2000);
    }

    modifier allowCommit() {
        if (!canCommit()) {
            revert TooEarly();
        }
        _;
    }

    function epochLength() public pure returns (uint16) {
        return 50;
    }

    function getEpoch() public view returns (uint256) {
        // 125 - 125 % 50 = 125 - 25 = 100;
        // 100 / 50 = 2;
        uint256 totalEpochs = (block.number - block.number % epochLength());
        return totalEpochs.mulDiv(1, epochLength());
    }

    function canCommit() public view returns (bool) {
        uint256 ep = getEpoch();
        return (ep * epochLength() + epochLength() / 2 >= block.number);
    }

    function commit(bytes32 hashValue) external allowCommit {
        hashValues[msg.sender] = hashValue;
    }

    function reveal(bytes32 secret, uint256 price) external {}
}
