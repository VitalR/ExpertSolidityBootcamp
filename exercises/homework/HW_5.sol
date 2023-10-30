// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
    Add 0x07 to 0x08 and store the result at the next free memory location.
 */

contract HW_5 {
    function add() public payable returns (uint256) {
        assembly {
            let ptr := mload(0x40)
            let free_mem := add(ptr, 0x20)
            let result := add(0x07, 0x08)
            mstore(free_mem, result)
            return(free_mem, 0x20)
        }
    }
}
