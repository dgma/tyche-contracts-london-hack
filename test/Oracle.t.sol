// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-global-import
// solhint-disable no-console

import "@std/Test.sol";

import {Oracle} from "src/Oracle.sol";

contract OracleTest is Test {
    Oracle private oracle;

    function setUp() public {
        oracle = new Oracle();
    }

    function test_decimals() public {
        assertEq(oracle.decimals(), 8);
    }

    function test_getPrice() public {
        uint256 expectedPrice = 2000 * 10 ** oracle.decimals();
        assertEq(oracle.getPrice(), expectedPrice);
    }
}
