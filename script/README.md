# Deployment Scripts

This directory contains Foundry deployment scripts for the EIP 8004 TEE Registry system.

## Architecture

The deployment is split into separate scripts for flexibility:

1. **DeployTEERegistry** - Deploys the core registry contract
2. **DeployDstackVerifier** - Deploys, configures, and registers the Dstack TDX verifier
3. **DeployNitroVerifier** - (Future) Deploys, configures, and registers the Nitro Enclave verifier

This modular approach allows you to:
- Deploy the registry once and add multiple verifiers over time
- Deploy verifiers to different registries
- Replace or upgrade individual verifiers without redeploying everything

## Quick Start

```bash
# 1. Deploy TEERegistry
forge script script/DeployTEERegistry.s.sol:DeployTEERegistry \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

# 2. Deploy and configure DstackVerifier (update .env with TEE_REGISTRY first)
forge script script/DeployDstackVerifier.s.sol:DeployDstackVerifier \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify \
  --optimism # enable RIP-7212 precompile support for OP Stack chains
```

## Script Files

### DeployTEERegistry.s.sol
- Deploys TEERegistry only
- Required: `IDENTITY_REGISTRY`

### DeployDstackVerifier.s.sol
Complete setup for DstackOffchainVerifier:
1. Deploys DstackOffchainVerifier
2. Sets reference measurement values
3. Initializes validator with TDX quote
4. Registers verifier in TEERegistry

Required: `TEE_REGISTRY`, `DCAP_VERIFIER`, `VALIDATOR_PUBKEY`, `VALIDATOR_TDX_QUOTE`, reference values

See .env.example for all required variables.
