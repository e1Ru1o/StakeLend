// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IStakeVault, IERC20} from "./interface/IStakeVault.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC4626Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import { ValidatorVerifier } from "./utils/ValidatorVerifier.sol";

enum VaultStatus {
    DEPOSITING,
    LENDING,
    LIQUIDATED,
    REPAID,
    CANCELLED
}

contract StakeVault is IStakeVault, ERC4626Upgradeable, ValidatorVerifier {
    using Math for uint256;

    uint256 public requiredAmount;
    uint256 public deadline;
    uint256 public rewardBPS;
    bytes private _pk;
    address private stakeLend;
    address private validator;
    VaultStatus public status;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        uint256 requiredAmount_,
        uint256 deadline_,
        uint256 rewardBPS_,
        bytes calldata pk,
        IERC20 usdc,
        address validator_
    ) external initializer {
        __ERC4626_init(usdc);
        requiredAmount = requiredAmount_;
        deadline = deadline_;
        rewardBPS = rewardBPS_;
        _pk = pk;
        stakeLend = msg.sender;
        validator = validator_;
        status = VaultStatus.DEPOSITING;
    }

    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        uint256 balance = IERC20(asset()).balanceOf(address(this));
        if (balance >= requiredAmount) {
            return 0;
        }
        uint256 topAmount = requiredAmount - balance;
        if (topAmount < assets) {
            assets = topAmount;
        }
        return super.deposit(assets, receiver);
    }

    /**
     * @inheritdoc ERC4626Upgradeable
     * @dev Implementation fallbacks to deposit function after computing assets amount
     *      with consideration to totalAssets and totalSupply
     */
    function mint(uint256 shares, address receiver) public override returns (uint256) {
        uint256 assets = previewMint(shares);
        return deposit(assets, receiver);
    }

    /**
     * @inheritdoc ERC4626Upgradeable
     * @dev Implementation fallbacks to redeem function after computing shares amount
     *      with consideration to totalAssets and totalSupply
     */
    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256) {
        uint256 shares = previewWithdraw(assets);
        return redeem(shares, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256) {
        VaultStatus status_ = status;
        if (status_ == VaultStatus.DEPOSITING || status_ == VaultStatus.REPAID) {
            return super.redeem(shares, receiver, owner);
        }
        if (status_ == VaultStatus.LIQUIDATED) {
            uint256 ethBalance = address(this).balance;
            uint256 ethShares = ethBalance.mulDiv(shares, totalSupply());
            payable(receiver).transfer(ethShares);
            return super.redeem(shares, receiver, owner);
        }
        revert("Not redeemable");
    }

    function lend() external {
        require(_msgSender() == validator, "Caller is not the validator");
        require(status == VaultStatus.DEPOSITING, "Not possible to lend");

        uint256 balance = IERC20(asset()).balanceOf(address(this));
        require(balance >= requiredAmount, "Not enough assets deposited");

        status = VaultStatus.LENDING;

        IERC20(asset()).transfer(validator, balance);
    }

    function repay() external {
        require(status == VaultStatus.LENDING, "Nothing to repay");
        uint256 payment = requiredAmount.mulDiv(10000 + rewardBPS, 10000);

        uint256 balanceBefore = IERC20(asset()).balanceOf(address(this));
        IERC20(asset()).transferFrom(msg.sender, address(this), payment);
        uint256 balanceAfter = IERC20(asset()).balanceOf(address(this));
        require(balanceAfter == balanceBefore + payment, "Repayment failed");

        status = VaultStatus.REPAID;
    }

    ////// Internals ///////

    function _msgSender() internal view override returns (address) {
        if (msg.sender == stakeLend) {
            address caller_;
            assembly {
                let position := sub(calldatasize(), 32)
                caller_ := calldataload(position)
            }
            return caller_;
        } else {
            return msg.sender;
        }
    }
}
