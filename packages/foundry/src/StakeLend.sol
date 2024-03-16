// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IStakeLend} from "./interface/IStakeLend.sol";
import {IStakeVault, IERC20} from "./interface/IStakeVault.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {AggregatorV3Interface} from "./interface/AggregatorV3Interface.sol";
import {EIP7002} from "./utils/EIP-7002.sol";

//TODO pk needs to be bytes calldata

contract StakeLend is IStakeLend, EIP7002 {
    using Clones for address;

    uint256 constant DENEB_ZERO_VALIDATOR_GINDEX = 798245441765376;
    uint256 PROOF_EXPIRY_TIME = 5 hours;
    AggregatorV3Interface internal usdDataFeed;
    

    mapping(bytes => address) private _credentialInUse;
    IStakeVault public vaultImplementation;
    IERC20 immutable usdc;

    constructor(IStakeVault vaultImplementation_, IERC20 usdc_, address _usdDataFeed) {
        vaultImplementation = vaultImplementation_;
        usdc = usdc_;
        usdDataFeed = AggregatorV3Interface(_usdDataFeed);
    }

    //TODO optimize with struct and pack?
    function liquidate(
        address _vaultAddress,
        bytes calldata _validatorPubKey,
        uint256 _validatorBalance,
        bytes32 _balanceProof,
        uint256 _proofTimestamp
    ) external view override {
        //TODO get vault data
        uint256 loanDeadline;
        uint256 minCollateralRatio;
        uint256 amountToRepay;

        //check if current timestamp is past loan deadline
        if (block.timestamp > loanDeadline) {
            trigger_exit(_vaultAddress, _validatorPubKey);
        }

        //verify validator balance is correct
        if (_validBalanceProof(_validatorPubKey, _validatorBalance, _balanceProof, _proofTimestamp)) {
            //check if min collateral ratio is not maintained
            if (_getEthPriceInUsdc(_validatorBalance) / amountToRepay < minCollateralRatio) {
                trigger_exit(_vaultAddress, _validatorPubKey);
            }
        }

        //revert liquidation
        revert();
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
        return abi.decode(_fowardCall(vault, data), (uint256));
    }

    function lend(address vault) external {
        //TODO get pk from vault
        bytes memory data = abi.encodeWithSelector(IStakeVault.lend.selector);
        //_credentialInUse[pk] = vault;
        _fowardCall(vault, data);
    }

    function repay(address vault) external {
        bytes memory data = abi.encodeWithSelector(IStakeVault.repay.selector);
        _fowardCall(vault, data);
    }

    function claim(address vault, uint256 shares, uint256 receiver, uint256 owner) external {
        bytes memory data = abi.encodeWithSelector(IERC4626.redeem.selector, shares, receiver, owner);
        _fowardCall(vault, data);
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

    function _fowardCall(address vault, bytes memory data) internal returns (bytes memory) {
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

    function _getEthPriceInUsdc(uint256 _ethAmount) internal view returns (uint256) {
        //chainlink oracle price feed to get eth price in usd
        (, int256 ethPrice,,,) = usdDataFeed.latestRoundData();
        //return total ether value
        return (uint256(ethPrice) * _ethAmount) / 10 ** 20; //get from 8 decimals to 6
    }

    function _validBalanceProof(bytes calldata, uint256, bytes32, uint256 _proofTimestamp)
        internal
        view
        returns (bool)
    {
        if (block.timestamp > _proofTimestamp + PROOF_EXPIRY_TIME) {
            return false;
        }
        //TODO check proof is valid
        return true;
    }
}
