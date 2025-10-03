// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

contract SignMockProof is Script {
    // Same logic as in test/TEERegistry.t.sol
    function getOffchainProof(uint256 mockValidatorKey, bytes32 code_measurement, address pubkey, string memory code_config_uri) public pure returns (bytes memory) {
        bytes memory message = abi.encode(code_measurement, pubkey, code_config_uri);

        bytes32 digest = keccak256(message);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(mockValidatorKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        return abi.encode(message, signature);
    }


    function run() external {
        uint256 mockValidatorKey = vm.envUint("VALIDATOR_KEY");
        bytes32 code_measurement = vm.envBytes32("CODE_MEASUREMENT");
        address pubkey = vm.envAddress("AGENT_PUBKEY");
        string memory code_config_uri = vm.envString("CODE_CONFIG_URI");

        bytes memory proof = getOffchainProof(mockValidatorKey, code_measurement, pubkey, code_config_uri);

        console.log("Code Measurement:");
        console.logBytes32(code_measurement);
        console.log("Agent Pubkey:");
        console.logAddress(pubkey);
        console.log("Code Config URI:");
        console.logString(code_config_uri);
        console.log("Mock Validator Key:");
        console.logUint(mockValidatorKey);

        console.log("Signed Mock Proof:");
        console.logBytes(proof);
    }
}
