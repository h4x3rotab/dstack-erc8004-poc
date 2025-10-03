// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @notice Reverses the byte order of a uint32.
function reverseByteOrderUint32(uint32 input) pure returns (uint32 v) {
    v = input;

    // swap bytes
    v = ((v & 0xFF00FF00) >> 8) | ((v & 0x00FF00FF) << 8);

    // swap 2-byte long pairs
    v = (v >> 16) | (v << 16);
}
