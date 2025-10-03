// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MockDcapVerifier
 * @notice Mock DCAP verifier for testing purposes
 * Returns hardcoded success responses for any TDX quote
 */
contract MockDcapVerifier {
    /**
     * @notice Mock implementation of verifyAndAttestOnChain
     * @dev Always returns success with empty output
     */
    function verifyAndAttestOnChain(bytes calldata) external pure returns (bool, bytes memory) {
        // Return success with empty output
        return (true, "");
    }
}
