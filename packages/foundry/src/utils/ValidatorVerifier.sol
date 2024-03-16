// SPDX-License-Identifier: MIT
//modification of https://github.com/madlabman/eip-4788-proof/
pragma solidity ^0.8.21;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { SSZ } from "./SSZ.sol";


contract ValidatorVerifier is Initializable {
    address public constant BEACON_ROOTS =
        0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    uint64 constant VALIDATOR_REGISTRY_LIMIT = 2 ** 40;

    /// @dev Generalized index of the first validator struct root in the
    /// registry.
    uint256 public gIndex;

    event Accepted(uint64 indexed validatorIndex);

    error RootNotFound();

    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 _gIndex
    ) external initializer {
        gIndex = _gIndex;
    }

    function proveValidator( //TODO adapts (remove) logs and return effective balance
        bytes32[] calldata validatorProof,
        SSZ.Validator calldata validator,
        uint64 validatorIndex,
        uint64 ts
    ) public {
        require(
            validatorIndex < VALIDATOR_REGISTRY_LIMIT,
            "validator index out of range"
        );

        uint256 gI = gIndex + validatorIndex;
        bytes32 validatoRoot = SSZ.validatorHashTreeRoot(validator);
        bytes32 blockRoot = getParentBlockRoot(ts);

        require(
            // forgefmt: disable-next-item
            SSZ.verifyProof(
                validatorProof,
                blockRoot,
                validatoRoot,
                gI
            ),
            "invalid validator proof"
        );

        emit Accepted(validatorIndex);
    }

    function getParentBlockRoot(uint64 ts)
        internal
        view
        returns (bytes32 root)
    {
        (bool success, bytes memory data) =
            BEACON_ROOTS.staticcall(abi.encode(ts));

        if (!success || data.length == 0) {
            revert RootNotFound();
        }

        root = abi.decode(data, (bytes32));
    }
}
