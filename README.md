# ERC-8004 TEERegistry

This repository demonstrates an implementation of **ERC-8004: TEE Key Registry**.

EIP 8004 enables agents running in TEEs to register their keys onchain after proving they were generated in a secure environment. This eliminates the need for frequent onchain transactions. Once a key is verified and registered, anyone trusting the TEE vendor and OS image can use the public key for encryption or signature verification.

**This repository includes:**
- `TEERegistry` contract implementation following ERC-8004
- `DstackOffchainVerifier` as a show case of our Intel TDX integartion
- Use Automata DCAP attestation library for attestation verification

## TEE Verification

### Current Implementation

This PoC implements a **two-stage verification architecture** for Intel TDX attestations via dstack:

#### Stage 1: Validator Initialization (`initValidator`)
The dstack verifier contract establishes a trusted validator through:

1. **DCAP Attestation Verification**: Validates the Intel TDX quote from the validator's TEE environment through Automata DCAP verifier
2. **Public Key Extraction**: Extracts the validator's Ethereum address from the TDX quote's report data (bytes 520+48 to 520+48+64)
3. **Measurement Verification**: Validates six critical TDX measurements against reference values:
   - `mrTd`: TDX module measurement
   - `mrConfigId`: Configuration measurement
   - `rtMr0-rtMr3`: Four runtime measurements capturing the container image and runtime state

Once validated, the validator's public key is stored on-chain as a trusted oracle.

#### Stage 2: Offchain Proof Verification (`verify`)
For each key registration, the verifier validates a compressed proof:

1. **Signature Verification**: Validates that the proof is signed by the trusted validator established in Stage 1
2. **Claim Verification**: Confirms the signed message contains the exact `codeMeasurement`, `pubkey`, and `codeConfigUri` being registered

This architecture moves expensive TEE attestation verification offchain while maintaining cryptographic integrity onchain. The validator acts as a trusted oracle that has proven its own TEE environment via DCAP attestation.

## Differences from Original ERC-8004 0.9 Draft

This implementation is **almost identical** to the original EIP 8004 proposal. The core architecture, security model, and contract interface remain unchanged.

### Extended Verifier Definition

The only substantive difference is that we've **generalized the verifier concept** to support both ZK proofs and indirect attestation models:

- **Original**: `zkVerifier` strictly refers to zero-knowledge proof verification
- **Current**: `verifier` supports both:
  1. **ZK proofs**: Direct onchain verification of TEE attestations (original model)
  2. **Indirect attestation**: Pre-authenticated validator oracles that have proven their TEE environment onchain and subsequently sign attestations offchain (as demonstrated in `DstackOffchainVerifier`)

This extension allows flexibility in verification approaches while maintaining the same security guarantees. Registry maintainers whitelist verifier contracts regardless of whether they use ZK circuits or oracle-based attestation.

### Minor Terminology Updates

- `imageUri` → `codeConfigUri` (clearer description of container configuration reference)
- `ZKVerifier` struct → `Verifier` struct (reflects generalized verifier definition)

All other aspects—access control, event emissions, key storage, and query methods—follow the original specification.
