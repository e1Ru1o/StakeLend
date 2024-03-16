// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SSZ} from "../utils/SSZ.sol";

interface IStakeVault {
    function initialize(
        uint256 _gIndex,
        uint256 requiredAmount_,
        uint256 deadline_,
        uint256 rewardBPS_,
        bytes calldata pk,
        IERC20 usdc,
        address _usdDataFeed,
        address validator
    ) external;

    function lend() external;

    function repay() external;

    function liquidate(
        bytes32[] calldata validatorProof,
        SSZ.Validator calldata validatorData,
        uint64 validatorIndex,
        uint64 timestamp
    ) external;
}
