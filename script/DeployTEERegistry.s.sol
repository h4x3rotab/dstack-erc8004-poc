// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../contracts/TEERegistry.sol";

/**
 * @title DeployTEERegistry
 * @notice Deployment script for TEERegistry
 *
 * This script only deploys the TEERegistry contract. Verifiers should be deployed
 * separately using their respective deployment scripts.
 *
 * Usage:
 *   Deploy to local network:
 *     forge script script/DeployTEERegistry.s.sol:DeployTEERegistry --rpc-url http://localhost:8545 --broadcast
 *
 *   Deploy to testnet/mainnet:
 *     forge script script/DeployTEERegistry.s.sol:DeployTEERegistry --rpc-url $RPC_URL --broadcast --verify
 *
 * Environment variables:
 *   IDENTITY_REGISTRY - Address of the identity registry contract (required)
 */
contract DeployTEERegistry is Script {
    function run() external {
        // Read deployment parameters from environment
        address identityRegistry = vm.envAddress("IDENTITY_REGISTRY");

        // Get deployer private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("=== TEERegistry Deployment ===");
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("Identity Registry:", identityRegistry);
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy TEERegistry
        console.log("Deploying TEERegistry...");
        TEERegistry registry = new TEERegistry(identityRegistry);
        console.log("TEERegistry deployed at:", address(registry));

        vm.stopBroadcast();

        console.log("");
        console.log("=== Deployment Summary ===");
        console.log("TEERegistry:", address(registry));
        console.log("Identity Registry:", registry.getIdentityRegistry());
        console.log("");
        console.log("Next steps:");
        console.log("1. Deploy verifiers (e.g., DeployDstackVerifier.s.sol)");
        console.log("2. Configure verifiers with reference values");
        console.log("3. Register agent keys using addKey()");
    }
}
