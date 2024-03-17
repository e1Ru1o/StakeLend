// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import { Test } from "forge-std/Test.sol";

import { SSZ } from "../src/SSZ.sol";
import { ValidatorVerifier } from "../src/ValidatorVerifier.sol";

contract ValidatorVerifierTest is Test {

    struct ProofJson {
        bytes32[] validatorProof;
        SSZ.Validator validator;
        uint64 validatorIndex;
        bytes32 blockRoot;
        uint256 block_;
        uint256 chain;
    }

    uint256 constant DENEB_ZERO_VALIDATOR_GINDEX = 798245441765376;

    ValidatorVerifier public verifier;
    ProofJson public proofJson;

    function setUp() public {
        string memory json = vm.readFile("./test/fixtures/validator_proof.json");
        bytes memory data = vm.parseJson(json);
        proofJson = abi.decode(data, (ProofJson));
    }

    function test_ProveValidator() public {
        uint64 ts = 31337;

        verifier = new ValidatorVerifier(DENEB_ZERO_VALIDATOR_GINDEX);

        vm.mockCall(
            verifier.BEACON_ROOTS(),
            abi.encode(ts),
            abi.encode(proofJson.blockRoot)
        );

        verifier.proveValidator(
            proofJson.validatorProof,
            proofJson.validator,
            proofJson.validatorIndex,
            ts
        );
    }

    function test_ProveValidator_OnFork() public {
        // Get fork url
        string memory forkUrl = vm.envOr("FORK_URL", string(""));
        vm.skip(_isEmptyString(forkUrl));
        
        // create fork
        vm.createSelectFork(forkUrl, proofJson.block_);
        // check the loaded data match the for
        vm.skip(_checkChainId(proofJson.chain)); // Only works on Goerli for now.

        verifier = new ValidatorVerifier(DENEB_ZERO_VALIDATOR_GINDEX);

        verifier.proveValidator(
            proofJson.validatorProof,
            proofJson.validator,
            proofJson.validatorIndex,
            uint64(block.timestamp)
        );
    }

    function _checkChainId(uint256 chainId) internal view returns (bool) {
        return chainId != block.chainid;
    }

    function _isEmptyString(string memory str) internal pure returns (bool) {
        return bytes(str).length == 0;
    }
}
