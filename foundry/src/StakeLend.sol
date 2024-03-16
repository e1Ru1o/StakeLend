// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IStakeLend} from "./interface/IStakeLend.sol";
import {IStakeVault, IERC20} from "./interface/IStakeVault.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract StakeLend is IStakeLend {
    using Clones for address;

    mapping(bytes => address) private _credentialInUse;
    IStakeVault public vaultImplementation;
    IERC20 immutable usdc;

    constructor(IStakeVault vaultImplementation_, IERC20 usdc_) {
        vaultImplementation = vaultImplementation_;
        usdc = usdc_;
    }

    function createVault(uint256 requiredAmount, uint256 deadline, uint256 rewardBPS, bytes calldata pk)
        external
        override
        returns (address)
    {
        require(_credentialInUse[pk] == address(0), "Credential already active");
        require(requiredAmount != 0, "Nothing to lend");
        IStakeVault vault = IStakeVault(
            address(vaultImplementation).cloneDeterministic(
                keccak256(abi.encodePacked(requiredAmount, deadline, rewardBPS, pk))
            )
        );
        vault.initialize(requiredAmount, deadline, rewardBPS, pk, usdc, msg.sender);
        return address(vault);
    }

    function fillVault(address vault, uint256 depositAmount) external returns (uint256) {
        bytes memory data = abi.encodeWithSelector(IERC4626.deposit.selector, depositAmount, msg.sender);
        return abi.decode(fowardCall(vault, data), (uint256));
    }

    function lend(address vault) external {
        bytes memory data = abi.encodeWithSelector(IStakeVault.lend.selector);
        fowardCall(vault, data);
    }

    function claim(address vault, uint256 shares, uint256 receiver, uint256 owner) external {
        bytes memory data = abi.encodeWithSelector(IERC4626.redeem.selector, shares, receiver, owner);
        fowardCall(vault, data);
    }

    ////// View functions ///////

    function getVaultAddress(uint256 requiredAmount, uint256 deadline, uint256 rewardBPS, bytes32 pk)
        public
        view
        returns (address)
    {
        return address(vaultImplementation).predictDeterministicAddress(
            keccak256(abi.encodePacked(requiredAmount, deadline, rewardBPS, pk))
        );
    }

    ////// Internals ////////

    function fowardCall(address vault, bytes memory data) internal returns (bytes memory) {
        bytes memory extraData = abi.encodePacked(data, uint256(uint160(msg.sender)));
        (bool success, bytes memory returndata) = vault.call(extraData);

        if (!success) {
            if (returndata.length == 0) revert();
            assembly {
                revert(add(32, returndata), mload(returndata))
            }
        }

        return returndata;
    }
}
