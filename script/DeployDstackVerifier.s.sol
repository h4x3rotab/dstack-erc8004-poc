// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../contracts/TEERegistry.sol";
import "../contracts/dstack-verifier/DstackVerifier.sol";
import "../contracts/dstack-verifier/IAutomataDcapAttestation.sol";

/**
 * @title DeployDstackVerifier
 * @notice Complete deployment and configuration script for DstackOffchainVerifier
 *
 * This script performs a full setup:
 * 1. Deploys DstackOffchainVerifier
 * 2. Sets reference measurement values
 * 3. Initializes the validator with TDX quote
 * 4. Registers the verifier in TEERegistry
 *
 * Usage:
 *   forge script script/DeployDstackVerifier.s.sol:DeployDstackVerifier --rpc-url $RPC_URL --broadcast
 *
 * Environment variables:
 *   TEE_REGISTRY - Address of the deployed TEERegistry contract (required)
 *   DCAP_VERIFIER - Address of the Automata DCAP verifier contract (required)
 *   VALIDATOR_PUBKEY - Ethereum address of the validator public key (required)
 *   VALIDATOR_TDX_QUOTE - Hex-encoded TDX quote for validator initialization (required)
 *   REFERENCE_MR_TD - Hex-encoded reference MR TD value (required)
 *   REFERENCE_MR_CONFIG_ID - Hex-encoded reference MR Config ID value (required)
 *   REFERENCE_RT_MR_0 - Hex-encoded reference RT MR 0 value (required)
 *   REFERENCE_RT_MR_1 - Hex-encoded reference RT MR 1 value (required)
 *   REFERENCE_RT_MR_2 - Hex-encoded reference RT MR 2 value (required)
 *   REFERENCE_RT_MR_3 - Hex-encoded reference RT MR 3 value (required)
 */
contract DeployDstackVerifier is Script {
    function run() external {
        // Read deployment parameters from environment
        address teeRegistryAddr = vm.envAddress("TEE_REGISTRY");
        address dcapVerifier = vm.envAddress("DCAP_VERIFIER");
        address validatorPubkey = vm.envAddress("VALIDATOR_PUBKEY");
        bytes memory validatorTdxQuote = vm.envBytes("VALIDATOR_TDX_QUOTE");

        bytes memory referenceMrTd = vm.envBytes("REFERENCE_MR_TD");
        bytes memory referenceMrConfigId = vm.envBytes("REFERENCE_MR_CONFIG_ID");
        bytes memory referenceRtMr0 = vm.envBytes("REFERENCE_RT_MR_0");
        bytes memory referenceRtMr1 = vm.envBytes("REFERENCE_RT_MR_1");
        bytes memory referenceRtMr2 = vm.envBytes("REFERENCE_RT_MR_2");
        bytes memory referenceRtMr3 = vm.envBytes("REFERENCE_RT_MR_3");

        // Get deployer private key, note that in the POC this should be the same as the TEERegistry deployer
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("=== DstackVerifier Deployment & Configuration ===");
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("TEE Registry:", teeRegistryAddr);
        console.log("DCAP Verifier:", dcapVerifier);
        console.log("Validator Pubkey:", validatorPubkey);
        console.log("");

        TEERegistry registry = TEERegistry(teeRegistryAddr);

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy DstackOffchainVerifier
        console.log("Step 1: Deploying DstackOffchainVerifier...");
        DstackOffchainVerifier verifier = new DstackOffchainVerifier(dcapVerifier);
        console.log("DstackOffchainVerifier deployed at:", address(verifier));
        console.log("");

        // Step 2: Set reference values
        console.log("Step 2: Setting reference values...");
        verifier.setReferenceValues(
            referenceMrTd,
            referenceMrConfigId,
            referenceRtMr0,
            referenceRtMr1,
            referenceRtMr2,
            referenceRtMr3
        );
        console.log("Reference values set successfully");
        console.log("");

        // Step 3: Initialize validator
        console.log("Step 3: Initializing validator...");
        verifier.initValidator(validatorPubkey, validatorTdxQuote);
        console.log("Validator initialized successfully");
        console.log("Validator public key:", verifier.validatorPublicKey());
        console.log("");

        // Step 4: Register verifier in TEERegistry
        console.log("Step 4: Registering verifier in TEERegistry...");
        bytes32 teeArch = bytes32("TDX-DSTACK");
        registry.addVerifier(address(verifier), teeArch);
        console.log("Verifier registered with TEE arch: TDX-DSTACK");

        vm.stopBroadcast();

        console.log("");
        console.log("=== Deployment Complete ===");
        console.log("DstackOffchainVerifier:", address(verifier));
        console.log("TEERegistry:", address(registry));
        console.log("DCAP Verifier:", verifier.dcapVerifier());
        console.log("Validator:", verifier.validatorPublicKey());
        console.log("Registered:", registry.isVerifier(address(verifier)));
        console.log("");
        console.log("DstackVerifier is now ready to verify proofs and register agent keys!");
    }
}
