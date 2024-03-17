// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract mockDepositContract {
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 depositDataRoot
    ) external payable {
        pubkey;
        withdrawal_credentials;
        signature;
        depositDataRoot;
    }
}
