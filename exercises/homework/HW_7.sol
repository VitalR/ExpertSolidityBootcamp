// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract HW7 {
    function query(uint _amount, address _receiver, bytes4 _selector) public  {
        (_selector);
        bytes4 selector = (bytes4(keccak256("transfer(address,uint)")));
        bytes memory data = abi.encode(selector, _receiver, _amount);

        (bool success, bytes memory result) = _receiver.call{value: 0}(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    error InvalidSelector();
    event TransferOccurred(address, uint256);

    function checkCall(bytes calldata data) external {
        (bytes4 selector, address receiver, uint amount) = abi.decode(data, (bytes4,address,uint));
       
        if (bytes4(selector) == bytes4(keccak256("transfer(address,uint256)"))) {
            emit TransferOccurred(receiver, amount);
        } else {
            revert InvalidSelector();
            
        }
    }

    function encodeDataForTransfer(address receiver, uint amount) external pure returns (bytes memory) {
        return abi.encode((bytes4(keccak256("transfer(address,uint256)"))),receiver,amount);
    }
}