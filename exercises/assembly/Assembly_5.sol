// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
    Create a Solidity contract with one function
    The solidity function should return the amount of ETH
    that was passed to it, and the function body should be
    written in assembly
 */

contract AssemblyEtherGetter {
    function getEtherPassed() public payable returns (uint256) {
        uint256 amount;

        assembly {
            amount := callvalue()
        }

        return amount;
    }
}
