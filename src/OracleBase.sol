// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Oracle} from "src/Oracle.sol";

contract OracleBase is Oracle {
    function epochLength() public pure override returns (uint32) {
        return 16;
    }
}
