// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Oracle} from "src/Oracle.sol";

contract OracleArbitrum is Oracle {
    // since arbitrum block.number is set to *delayed* L1,
    // we need to carefully decrease epoch length
    function epochLength() public pure override returns (uint32) {
        return 32;
    }
}
