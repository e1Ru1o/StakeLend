// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IStakeVault {
    function initialize(
        uint256 _gIndex,
        uint256 requiredAmount_,
        uint256 deadline_,
        uint256 rewardBPS_,
        bytes calldata pk,
        IERC20 usdc,
        address validator
    ) external;

    function lend() external;

    function repay() external;
}
