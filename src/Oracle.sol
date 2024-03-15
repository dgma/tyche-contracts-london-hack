// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IOracle} from "src/Oracle.types.sol";

contract Oracle is IOracle {
    function _convert(uint256 value) private pure returns (uint256) {
        return value * 10 ** decimals();
    }

    function decimals() public pure returns (uint8) {
        return 8;
    }

    function getPrice() external pure returns (uint256) {
        return _convert(2000);
    }
}
