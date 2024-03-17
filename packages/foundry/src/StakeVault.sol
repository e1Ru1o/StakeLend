// SPDX-License-Identifier: MIT
//modification of https://github.com/madlabman/eip-4788-proof/
pragma solidity ^0.8.24;

import {IStakeVault, IERC20, SSZ} from "./interfaces/IStakeVault.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC4626Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {EIP7002} from "./utils/EIP7002.sol";
import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";
import {mockDepositContract} from "./utils/mockDepositContract.sol";

enum VaultStatus {
    DEPOSITING,
    LENDING,
    LIQUIDATED,
    REPAID,
    CANCELLED
}

interface IDepositContract {
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 depositDataRoot
    ) external payable;
}

contract StakeVault is IStakeVault, ERC4626Upgradeable, EIP7002 {
    using Math for uint256;

    address public constant BEACON_ROOTS =
        0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;
    address public DEPOSIT_CONTRACT; //set to mock for demo because of sepolia (todo later)
        //0x00000000219ab540356cBB839Cbe05303d7705Fa;
    uint64 constant VALIDATOR_REGISTRY_LIMIT = 2 ** 40;
    uint256 constant LIQUIDATION_FLOOR_LIMIT_BPS = 1_000; //10%
    uint256 PROOF_EXPIRY_TIME = 12 hours;

    AggregatorV3Interface internal usdDataFeed;
    uint256 public requiredAmount;
    uint256 public deadline;
    uint256 public rewardBPS;
    bytes public _pk;
    address public stakeLend;
    address public validator;
    VaultStatus public status;

    /// @dev Generalized index of the first validator struct root in the
    /// registry.
    uint256 public gIndex;

    error RootNotFound();

    constructor() {
        _disableInitializers();
    }

    function initialize(
        uint256 _gIndex,
        uint256 requiredAmount_,
        uint256 deadline_,
        uint256 rewardBPS_,
        IERC20 usdc,
        address _usdDataFeed,
        address validator_
    ) external override initializer {
        gIndex = _gIndex;
        __ERC4626_init(usdc);
        usdDataFeed = AggregatorV3Interface(_usdDataFeed);
        requiredAmount = requiredAmount_;
        deadline = deadline_;
        rewardBPS = rewardBPS_;
        stakeLend = msg.sender;
        validator = validator_;
        status = VaultStatus.DEPOSITING;
        DEPOSIT_CONTRACT = address(new mockDepositContract());
    }

    function deposit(
        uint256 assets,
        address receiver
    ) public override returns (uint256) {
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
    function mint(
        uint256 shares,
        address receiver
    ) public override returns (uint256) {
        uint256 assets = previewMint(shares);
        return deposit(assets, receiver);
    }

    /**
     * @inheritdoc ERC4626Upgradeable
     * @dev Implementation fallbacks to redeem function after computing shares amount
     *      with consideration to totalAssets and totalSupply
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override returns (uint256) {
        uint256 shares = previewWithdraw(assets);
        return redeem(shares, receiver, owner);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public override returns (uint256) {
        VaultStatus status_ = status;
        if (status_ == VaultStatus.DEPOSITING || status_ == VaultStatus.REPAID)
        {
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

    function lend(
        bytes calldata pk,
        bytes calldata signature,
        bytes32 depositDataRoot
    ) external payable {
        require(_msgSender() == validator, "Caller is not the validator");
        require(
            msg.sender == stakeLend, "Call needs to be router trough StakeLend"
        );
        require(status == VaultStatus.DEPOSITING, "Not possible to lend");
        require(msg.value == 0.01 ether, "No enough assets to stake"); //set to 0.01 ether instead of 32 for demo (todo later)

        bytes32 withdrawalCredentials =
            bytes32(uint256(uint160(address(this))) | (uint256(0x1) << 248));

        IDepositContract(DEPOSIT_CONTRACT).deposit{value: msg.value}(
            pk,
            abi.encodePacked(withdrawalCredentials),
            signature,
            depositDataRoot
        );

        uint256 balance = IERC20(asset()).balanceOf(address(this));
        require(balance >= requiredAmount, "Not enough assets deposited");

        status = VaultStatus.LENDING;
        _pk = pk;

        IERC20(asset()).transfer(validator, balance);
    }

    function liquidate(
        bytes32[] calldata validatorProof,
        SSZ.Validator calldata validatorData,
        uint64 validatorIndex,
        uint64 timestamp
    ) external override {
        require(status == VaultStatus.LENDING, "Nothing to liquidate");
        require(
            timestamp + PROOF_EXPIRY_TIME > block.timestamp, "Proof is expired"
        );

        //reverts if proof is not valid
        (bytes calldata validatorPubKey, uint256 validatorBalance) =
        proveValidator(validatorProof, validatorData, validatorIndex, timestamp);

        require(
            keccak256(_pk) == keccak256(validatorPubKey),
            "Validator public key does not belong to vault"
        );

        //check if min collateral ratio is not maintained
        uint256 owedAmount =
            (requiredAmount + (requiredAmount * rewardBPS) / 10000);
        uint256 currentAmount = _getEthPriceInUsdc(validatorBalance);
        if (
            owedAmount > currentAmount
                || currentAmount - owedAmount
                    < ((owedAmount * LIQUIDATION_FLOOR_LIMIT_BPS) / 10000)
        ) {
            trigger_exit(address(this), validatorPubKey);
            status == VaultStatus.LIQUIDATED;
        } else {
            //revert liquidation
            revert();
        }
    }

    function liquidateExpiredDebt() external override {
        require(status == VaultStatus.LENDING, "Nothing to liquidate");

        //check if current timestamp is past loan deadline
        if (block.timestamp > deadline) {
            trigger_exit(address(this), _pk);
            status = VaultStatus.LIQUIDATED;
            return;
        }
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

    function _getEthPriceInUsdc(uint256 _ethAmount)
        internal
        view
        returns (uint256)
    {
        //chainlink oracle price feed to get eth price in usd
        (, int256 ethPrice,,,) = usdDataFeed.latestRoundData();
        //return total ether value
        return (uint256(ethPrice) * _ethAmount) / 10 ** 20; //get from 8 decimals to 6
    }

    //@dev checks if the proof is valid and if so returns the validators public key and effective balance
    function proveValidator(
        bytes32[] calldata validatorProof,
        SSZ.Validator calldata validatorData,
        uint64 validatorIndex,
        uint64 ts
    ) internal view returns (bytes calldata, uint256) {
        require(
            validatorIndex < VALIDATOR_REGISTRY_LIMIT,
            "validator index out of range"
        );

        uint256 gI = gIndex + validatorIndex;
        bytes32 validatoRoot = SSZ.validatorHashTreeRoot(validatorData);
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

        return (validatorData.pubkey, uint256(validatorData.effectiveBalance));
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
