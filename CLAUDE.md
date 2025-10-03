# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a Proof of Concept implementation for **EIP 8004: TEE Key Registry**. The purpose is to enable agents running in Trusted Execution Environments (TEEs) to register their secp256k1 public keys on-chain after cryptographic verification.

### Core Concept

1. Agents run inside TEEs and generate TEE-protected secp256k1 key pairs
2. TEE attestation documents prove the key was generated in a secure environment
3. Zero-knowledge proofs verify the attestation without revealing sensitive data
4. Upon successful verification, the public key and code measurement are registered on-chain
5. Anyone trusting the TEE vendor and container image can then use the public key for encryption or signature verification

## Architecture

### Smart Contract Structure

The repository implements the TEE Key Registry specification from EIP 8004:

- **[ITEERegistry.sol](contracts/ITEERegistry.sol)**: Interface defining the registry contract structure
  - Manages whitelisted zkVerifier contracts that validate TEE attestations
  - Stores keys indexed by `agentId` with metadata: `teeArch`, `codeMeasurement`, `pubkey`, `imageUri`, `zkVerifier`
  - Access control: only agent owners/operators can add/remove keys for their agentId

- **[TEERegistry.sol](contracts/TEERegistry.sol)**: Main implementation (currently empty - to be implemented)

- **[DstackVerifier.sol](contracts/DstackVerifier.sol)**: ZK verifier implementation for Dstack TEE attestations (currently empty - to be implemented)

### Key Registration Flow

1. Agent generates TEE attestation document
2. Agent uses local computation or proving cloud to create ZK proof of attestation verification
3. Proof includes public inputs: code measurement (hash) and agent's secp256k1 public key
4. Proof submitted on-chain and verified by whitelisted zkVerifier contract
5. On successful verification, zkVerifier calls `TEERegistry.addKey()`
6. Registry records the association between agentId, code measurement, and public key

### Data Structures

**ZKVerifier struct:**
- `teeArch`: Identifies TEE architecture (Intel SGX, AWS Nitro, AMD SEV, etc.)

**Key struct:**
- `teeArch`: TEE architecture identifier
- `codeMeasurement`: Cryptographic hash of code running in TEE
- `pubkey`: secp256k1 public key generated in TEE
- `imageUri`: URI to container image/code specification
- `zkVerifier`: Address of verifier contract that validated this key

## Development Status

This is an early-stage PoC. The main contracts (TEERegistry.sol and DstackVerifier.sol) are currently empty placeholders. The interface (ITEERegistry.sol) defines the contract structure based on the EIP 8004 specification.

### Implementation Notes

- The attestation verification logic in zkVerifier contracts MUST be open source and pre-audited
- Registry maintainers are responsible for whitelisting/removing trusted zkVerifier contracts
- Agents must disclose their source code and provide guidance for verifying code measurements
- Reputation management for codebases/container images is outside the scope of EIP 8004
