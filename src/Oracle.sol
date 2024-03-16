// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {OracleMath} from "src/libs/OracleMath.sol";
import {ArraySort} from "src/libs/ArraySort.sol";
import {IOracle, CommitTooEarly, RevealTooEarly, InvalidReveal} from "src/Oracle.types.sol";

contract Oracle is IOracle {
    using OracleMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private nodesRegistry;
    mapping(address => bytes32) private hashValues;
    mapping(uint256 => uint256) private epochRandom;
    mapping(uint256 => uint256[]) private epochRevealedPrices;
    mapping(uint256 => uint256) private epochPrice;

    modifier allowCommit() {
        if (!canCommit()) {
            revert CommitTooEarly();
        }
        _;
    }

    modifier allowReveal() {
        if (!canReveal()) {
            revert RevealTooEarly();
        }
        _;
    }

    function priceCommetiSize() public pure virtual returns (uint16) {
        return 5;
    }

    function decimals() public pure virtual returns (uint8) {
        return 8;
    }

    function epochLength() public pure virtual returns (uint32) {
        return 50;
    }

    function getPrevRandom() private view returns (uint256) {
        uint256 ep = getActiveEpoch();
        if (ep == 0) {
            return 0;
        }
        return epochRandom[(ep - 1)];
    }

    function getBlockNumber() internal view virtual returns (uint256) {
        return block.number;
    }

    function getPrice() external view returns (uint256) {
        uint256 ep = getActiveEpoch();
        if (ep == 0) {
            return 0;
        }
        return epochPrice[ep - 1];
    }

    function getActiveEpoch() public view returns (uint256) {
        return getBlockNumber().floorDiv(epochLength());
    }

    // 0 - 24
    function _getMaxCommimentBlock() private view returns (uint256) {
        return getActiveEpoch() * epochLength() + epochLength() / 2 - 1;
    }
    // 0 - 24

    function _getMinCommimentBlock() private view returns (uint256) {
        return getActiveEpoch() * epochLength();
    }

    // 25 - 49
    function _getMaxRevealBlock() private view returns (uint256) {
        return getActiveEpoch() * epochLength() + epochLength() - 1;
    }

    // 25 - 49
    function _getMinRevealBlock() private view returns (uint256) {
        return _getMaxCommimentBlock() + 1;
    }

    function canCommit() public view returns (bool) {
        uint256 blockNum = getBlockNumber();
        uint256 random = getPrevRandom();
        bool isCommitPhase =
            _getMinCommimentBlock() <= blockNum && blockNum <= _getMaxCommimentBlock();
        if (!isCommitPhase) {
            return false;
        }

        // allow to articipate enyone at initial stage
        if (random == 0) {
            return nodesRegistry.contains(msg.sender);
        } else {
            uint256 regLen = nodesRegistry.length();
            uint256 nodeIndex = random % regLen;
            uint256 step = regLen.ceilDiv(2);
            for (uint256 i = 0; i < priceCommetiSize(); i++) {
                if (nodeIndex >= regLen) {
                    nodeIndex = nodeIndex % regLen;
                }
                if (nodesRegistry.at(nodeIndex) == msg.sender) {
                    return isCommitPhase;
                }
                nodeIndex += step;
            }
            return false;
        }
    }

    function canReveal() public view returns (bool) {
        uint256 blockNum = getBlockNumber();
        return (_getMinRevealBlock() <= blockNum && blockNum <= _getMaxRevealBlock());
    }

    function commit(bytes32 hashValue) external allowCommit {
        hashValues[msg.sender] = hashValue;
    }

    function reveal(uint256 secret, uint256 price) external allowReveal {
        if (!(hashValues[msg.sender] == keccak256(abi.encode(price, secret)))) {
            revert InvalidReveal();
        }
        uint256 ep = getActiveEpoch();
        uint256 random = epochRandom[ep] ^ secret;
        epochRandom[ep] = random;
        epochRevealedPrices[ep].push(price);
        uint256 len = epochRevealedPrices[ep].length;
        uint256 indexesToGrab = len.ceilDiv(3);
        uint256 priceIndex = random % len;
        if (indexesToGrab == 1) {
            epochPrice[ep] = epochRevealedPrices[ep][priceIndex];
        } else {
            uint256 step = len.ceilDiv(10);
            uint256[] memory selectedPrices = new uint256[](indexesToGrab);
            for (uint256 i = 0; i < indexesToGrab; i++) {
                if (priceIndex >= len) {
                    priceIndex = priceIndex % len;
                }
                selectedPrices[i] = epochRevealedPrices[ep][priceIndex];
                priceIndex += step;
            }
            ArraySort.bubble(selectedPrices, indexesToGrab);
            epochPrice[ep] = selectedPrices[indexesToGrab.ceilDiv(2)];
        }
    }

    function register() external {
        nodesRegistry.add(msg.sender);
    }

    function unRegister() external {
        nodesRegistry.remove(msg.sender);
    }
}
