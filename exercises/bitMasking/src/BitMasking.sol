// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract BitMasking {
    uint16 public a;
    uint16 public b = 0xbeef;
    uint32 public c;
    uint64 public d;
    uint128 public e = 0x0000ca11ab1ebeef00000000feedbee5;

    function getSlot() external view returns (bytes32 ret) {
        assembly {
            ret := sload(0)
        }
    }

    // TODO:
    // 1. Read variable b and return its value 0xbeef

    // SOLVED:
    function readBeef() external view returns (bytes32 ret) {
        assembly {
            // Solution: shift right slot `0`, then and masking with 0xffff
            // This line loads the data from the storage slot where b is located.
            // b.slot refers to the storage slot number of the variable b. 
            // sload is an assembly function that reads data from a specific storage slot.
            let value := sload(b.slot)

            // This line stores the offset of b within its storage slot into a variable named offset. 
            // In Solidity, multiple small-sized state variables can be packed into the same storage slot to save space. 
            // b.offset tells us where within the slot b's data starts.
            let offset := b.offset

            // This line performs a bitwise right shift on value. 
            // The shift amount is determined by multiplying the offset by 8 (since there are 8 bits in a byte, and offset is in terms of bytes). 
            // This aligns the desired value (b) to the least significant position.
            let shifted := shr(mul(offset, 8), value)

            // This line uses a bitwise AND operation with 0xffff (which is 16 bits long, all set to 1) on the shifted value. 
            // This operation masks out all but the least significant 16 bits, effectively isolating the value of b.
            ret := and(0xffff, shifted)

            // The function returns ret, which now holds the 16-bit value of b (0xbeef) in a bytes32 type, making sure it fits the return type of the function.
            
            // Emitting a log with one indexed argument
            // `log1` takes 5 arguments:
            // - memory start (pointer to the data to log)
            // - memory size (size of the data to log)
            // - topic1 (first indexed argument)
            // You can use the `mstore` operation to store the data in memory before logging
            // mstore(0x80, value)
            // mstore(0xA0, offset)
            // mstore(0xC0, shifted)
            // mstore(0xE0, ret)
            // log1(0x80, 0x80, 0x00) // Emit log with data starting at 0x80, size 0x80, and topic 0x00
        }
    }

    // TODO:
    // 1. Store 0xf00dc0de in variable c
    // 2. Store 0xc0ffee0000d15ea5 in variable d
    // Note: use yul, bit shifting and bit masking only

    // SOLVED: Challenge 1
    function foodCode() external {
        assembly {
            let currentSlotValue := sload(0) // Read the current value of the slot
            let maskForC := 0xFFFFFFFF // Mask to isolate `c` (32 bits)
            maskForC := shl(32, maskForC) // Shift the mask to align with `c`
            maskForC := not(maskForC) // Invert the mask to clear the space for `c`
            currentSlotValue := and(currentSlotValue, maskForC) // Clear `c` space in the slot
            let shiftedNewValue := shl(16, 0xf00dc0de) // Align `newValue` with `c`'s position
            currentSlotValue := and(currentSlotValue, maskForC) // Clear `c` space in the slot
            currentSlotValue := or(currentSlotValue, shiftedNewValue) // Insert `newValue` into the slot
            sstore(0, currentSlotValue) // Write back the modified value
        }
    }

    // SOLVED: Challenge 2
    function foodCode2() external {
        assembly {
            let currentSlotValue := sload(0) // Read the current value of the slot
            let maskForD := 0xFFFFFFFFFFFFFFFF // 64-bit mask to isolate `d`
            maskForD := shl(64, maskForD) // Shift the mask to align with `d`'s position (after `a`, `b`, and `c`)
            maskForD := not(maskForD) // Invert the mask to clear the space for `d`
            currentSlotValue := and(currentSlotValue, maskForD) // Clear `d` space in the slot
            let shiftedNewValue := shl(64, 0xc0ffee0000d15ea5) // Align the new value with `d`'s position
            currentSlotValue := or(currentSlotValue, shiftedNewValue) // Insert the new value into the slot
            sstore(0, currentSlotValue) // Write back the modified value
        }
    }

    // TODO:
    // 1. Modify the first two bytes of variable e to be `0xce00`
    // 2. Put 0xfaceb00c from the 9th to 12th byte of variable e inplace

    // FIXME: Challenge 2
    function facebooc() external {
        assembly {
            let slot0 := sload(0)
            // start here
        }
    }

    // TODO:
    // 1. For variable e, leave the byte words `beef` and `bee` inplace, discard all other non-zero bytes words
    // 2. For variable d, mask the word `fee`, add 1/2 byte `d` to `fee` so that it reads `feed`
    // NOTE: If all variable are updated correctly, slot 0 should return 0xbeef000000000000bee0000feed00000000000000000beef0000

    // FIXME: Challenge 3
    function beefBeeFeedBeef() external {
        this.foodCode();
        this.facebooc();
        assembly {
            let slot0 := sload(0)
            // start here
        }
    }
}
