// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ArraySort {
    // credit to
    // https://gist.github.com/Tofunmi1/6db53e88d071b3c4a17d5d292a87dde1#file-bubblesort-sol
    function bubble(uint256[] memory _arr, uint256 n) public pure {
        if (n == 0 || n == 1) {
            return;
        }

        for (uint256 i = 0; i < n - 1;) {
            if (_arr[i] > _arr[i + 1]) {
                (_arr[i], _arr[i + 1]) = (_arr[i + 1], _arr[i]);
            }
            unchecked {
                ++i;
            }
        }
        bubble(_arr, n - 1);
    }
}
