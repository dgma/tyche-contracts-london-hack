// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-global-import
// solhint-disable no-console

import "@std/Test.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {Oracle} from "src/Oracle.sol";

import "forge-std/console.sol";

contract OracleTest is Test {
    Oracle private oracle;

    function setUp() public {
        oracle = new Oracle();
        oracle.register();
    }

    function test_decimals() public {
        assertEq(oracle.decimals(), 8);
    }

    function test_getEpochLength() public {
        assertEq(oracle.epochLength(), 50);
    }

    function test_getActiveEpoch() public {
        assertEq(oracle.getActiveEpoch(), 0);
        vm.roll(13);
        assertEq(oracle.getActiveEpoch(), 0);
        vm.roll(oracle.epochLength());
        assertEq(oracle.getActiveEpoch(), 1);
        vm.roll(oracle.epochLength() + oracle.epochLength() / 2);
        assertEq(oracle.getActiveEpoch(), 1);
    }

    function testFuzz_getActiveEpoch(uint256 blockNum) public {
        vm.assume(blockNum < oracle.epochLength());
        vm.roll(blockNum);
        assertEq(oracle.getActiveEpoch(), 0);
    }

    function testFuzz_getActiveEpochBig(uint256 blockNum) public {
        vm.assume(oracle.epochLength() * 50 < blockNum);
        vm.roll(blockNum);
        assert(oracle.getActiveEpoch() >= 50);
    }

    function testFuzz_canCommit(uint256 blockNum, uint256 epoch) public {
        // any first 25 blocks of epoch
        vm.assume(
            epoch < type(uint256).max / oracle.epochLength()
                && oracle.epochLength() * epoch < blockNum
                && blockNum < oracle.epochLength() * epoch + oracle.epochLength() / 2
        );
        vm.roll(blockNum);
        assertEq(oracle.canCommit(), true);
    }

    function test_canNotCommit() public {
        vm.roll(25);
        assertEq(oracle.canCommit(), false);
    }

    function test_canReveal() public {
        vm.roll(49);
        assertEq(oracle.canReveal(), true);
    }

    function test_canNotReveal(uint256 blockNum) public {
        vm.assume(blockNum < 25);
        vm.roll(blockNum);
        assertEq(oracle.canReveal(), false);
    }

    function testFuzz_revealOne(uint256 secret, uint256 price) public {
        bytes32 commitedHash = keccak256(abi.encode(price, secret));
        oracle.commit(commitedHash);
        vm.roll(26);
        oracle.reveal(secret, price);
        assertEq(oracle.getPrice(), price);
    }

    function _genAddrs() private returns (address[10] memory addresses) {
        for (uint8 i = 0; i < 10; i++) {
            string memory s = Strings.toString(i);
            addresses[i] = makeAddr(s);
            hoax(addresses[i]);
            oracle.register();
        }
    }

    function _doCommits(
        uint256[10] memory secrets,
        uint256[10] memory prices,
        address[10] memory addresses
    ) private {
        for (uint8 i = 0; i < 10; i++) {
            bytes32 h = keccak256(abi.encode(prices[i], secrets[i]));
            hoax(addresses[i]);
            oracle.commit(h);
        }
    }

    function _doReveals(
        uint256[10] memory secrets,
        uint256[10] memory prices,
        address[10] memory addresses
    ) private {
        for (uint8 i = 0; i < 10; i++) {
            hoax(addresses[i]);
            oracle.reveal(secrets[i], prices[i]);
        }
    }

    function _genPrices(uint256 price1, uint256 price2)
        private
        pure
        returns (uint256[10] memory prices)
    {
        for (uint8 i = 0; i < 10; i++) {
            if (i < 3) prices[i] = price1;
            else prices[i] = price2;
        }
    }

    function testFuzz_revealTen(uint256[10] memory secrets, uint256 price1, uint256 price2)
        public
    {
        uint256[10] memory prices = _genPrices(price1, price2);
        address[10] memory addresses = _genAddrs();
        _doCommits(secrets, prices, addresses);
        vm.roll(26);
        _doReveals(secrets, prices, addresses);
        assert(oracle.getPrice() == price1 || oracle.getPrice() == price2);
    }

    function test_xxx() public view {
        console.logBytes32(keccak256(abi.encode(472583180087, 254384457050125)));
        assert(true);
    }
}
