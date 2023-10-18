// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SubOverflow {
    // Modify this function so that on overflow it returns the value 0
    // otherwise it should return x - y
    function subtract(uint256 x, uint256 y) public pure returns (uint256) {
        // Write assembly code that handles overflows
        assembly {
            let result
            if gt(x, y) {
                result := sub(x, y)
                mstore(0x80, result)
            }
            if lt(x, y) {
                result := 0
                mstore(0x80, result)
            }
            return (0x80, 32)
        }
    }
}
