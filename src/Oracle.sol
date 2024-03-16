// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {OracleMath} from "src/libs/OracleMath.sol";
import {ArraySort} from "src/libs/ArraySort.sol";
import {IOracle, CommitTooEarly, RevealTooEarly, InvalidReveal} from "src/Oracle.types.sol";

contract Oracle is IOracle {
    using OracleMath for uint256;

    mapping(address => bytes32) private hashValues;
    mapping(uint256 => uint256) private epochRandom;
    mapping(uint256 => uint256[]) private epochRevealedPrices;
    mapping(uint256 => uint256) private epochPrice;

    function decimals() public pure virtual returns (uint8) {
        return 8;
    }

    // adjust it to different L2s
    function epochLength() public pure virtual returns (uint16) {
        return 50;
    }

    function getPrice() external view returns (uint256) {
        return epochPrice[getActiveEpoch()];
    }

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

    // adjust it to different L2s
    function getL1BlockNumber() internal view virtual returns (uint256) {
        return block.number;
    }

    function getActiveEpoch() public view returns (uint256) {
        return getL1BlockNumber().floorDiv(epochLength());
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
        uint256 blockNum = getL1BlockNumber();
        return (_getMinCommimentBlock() <= blockNum && blockNum <= _getMaxCommimentBlock());
    }

    function canReveal() public view returns (bool) {
        uint256 blockNum = getL1BlockNumber();
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
}
