// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "solady/auth/Ownable.sol";
import {INitroEnclaveVerifier, ZkCoProcessorType, VerifierJournal, VerificationResult} from "./INitroEnclaveVerifier.sol";
import {ITEEVerifier} from "../ITEEVerifier.sol";

import {console} from "forge-std/console.sol";

/**
 * @title NitroEnclaveVerifierAdapter
 * @dev Adapter for AWS Nitro Enclave attestations that implements the EIP 8004 ITEEVerifier interface
 *
 * This contract wraps the NitroEnclaveVerifierCore (which does ZK proof verification)
 * and provides a standardized EIP 8004 interface for the TEERegistry.
 * It calls NitroEnclaveVerifierCore, then validates code measurements and public keys.
 */
contract NitroEnclaveVerifierAdapter is ITEEVerifier, Ownable {
    address public zkVerifier;

    event ZKVerifierSet(address indexed verifier);

    constructor(address _zkVerifier) {
        _initializeOwner(msg.sender);
        zkVerifier = _zkVerifier;
    }

    function setZKVerifier(address verifier) external onlyOwner {
        zkVerifier = verifier;
        emit ZKVerifierSet(verifier);
    }

    /**
     * @dev Verify Nitro Enclave attestation proof
     *
     * @param identityRegistry - Address of the identity registry (available for verifiers that need it)
     * @param agentId - The agent ID (available for verifiers that need it)
     * @param codeMeasurement - Expected code measurement hash (computed from PCRs)
     * @param pubkey - Expected public key (as address)
     * @param codeConfigUri - Expected code configuration URI
     * @param proof - Encoded proof data containing (ZkCoProcessorType, output, proofBytes)
     * @return bool - True if verification succeeds
     */
    function verify(
        address identityRegistry,
        uint256 agentId,
        bytes32 codeMeasurement,
        address pubkey,
        string calldata codeConfigUri,
        bytes calldata proof
    ) external returns (bool) {
        require(zkVerifier != address(0), "Invalid zkVerifier");

        // Decode proof data
        (ZkCoProcessorType zkCoprocessor, bytes memory output, bytes memory proofBytes) =
            abi.decode(proof, (ZkCoProcessorType, bytes, bytes));

        // Verify the attestation using the ZK verifier (RISC Zero or SP1)
        // This calls the actual zero-knowledge proof verification
        VerifierJournal memory journal =
            INitroEnclaveVerifier(zkVerifier).verify(output, zkCoprocessor, proofBytes);

        // Check verification result
        require(journal.result == VerificationResult.Success, "Attestation verification failed");

        // Compute the hash of all PCR values for codeMeasurement
        bytes memory allPcrBytes = new bytes(journal.pcrs.length * 48);
        uint256 offset = 0;
        for (uint256 i = 0; i < journal.pcrs.length; i++) {
            bytes32 first = journal.pcrs[i].value.first;
            for (uint256 j = 0; j < 32; j++) {
                allPcrBytes[offset + j] = first[j];
            }
            bytes16 second = journal.pcrs[i].value.second;
            for (uint256 j = 0; j < 16; j++) {
                allPcrBytes[offset + 32 + j] = second[j];
            }
            offset += 48;
        }
        bytes32 computedCodeMeasurement = keccak256(allPcrBytes);

        // Verify the computed code measurement matches the expected one
        require(computedCodeMeasurement == codeMeasurement, "Code measurement mismatch");

        // Verify public key matches (convert bytes to address)
        require(journal.publicKey.length >= 20, "Invalid public key length");
        address extractedPubkey = address(bytes20(journal.publicKey));
        require(extractedPubkey == pubkey, "Public key mismatch");

        // Note: codeConfigUri validation could be added here if needed
        // For now, we trust that the caller provides the correct URI

        return true;
    }
}
