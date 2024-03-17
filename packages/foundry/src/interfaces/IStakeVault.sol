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
        IERC20 usdc,
        address _usdDataFeed,
        address validator
    ) external;

    /**
     * Lend the assets deposited in the vault
     * @param pk A BLS12-381 public key.
     * @param signature A BLS12-381 signature.
     * @param depositDataRoot The SHA-256 hash of the SSZ-encoded DepositData object.
     */
    function lend(
        bytes calldata pk,
        bytes calldata signature,
        bytes32 depositDataRoot
    ) external payable;

    function repay() external;

    function liquidate(
        bytes32[] calldata validatorProof,
        SSZ.Validator calldata validatorData,
        uint64 validatorIndex,
        uint64 timestamp
    ) external;

    /**
     * Triggers the validators exit from the beacon chain if
     * the repayment deadline is passed
     */
    function liquidateExpiredDebt() external;
}
