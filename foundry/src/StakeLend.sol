// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interface/AggregatorV3Interface.sol";
import "./utils/EIP-7002.sol";

contract StakeLend is EIP7002 {
    uint256 PROOF_EXPIRY_TIME = 5 hours;
    AggregatorV3Interface internal usdDataFeed;

    constructor(address _usdDataFeed) {
        usdDataFeed = AggregatorV3Interface(_usdDataFeed);
    }

    //TODO optimize with struct and pack?
    function liquidate(
        address _vaultAddress,
        bytes calldata _validatorPubKey,
        uint256 _validatorBalance,
        bytes32 _balanceProof,
        uint256 _proofTimestamp
    ) external {
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

    function _getEthPriceInUsdc(uint256 _ethAmount) internal returns (uint256) {
        //chainlink oracle price feed to get eth price in usd
        (, int256 ethPrice,,,) = usdDataFeed.latestRoundData();
        //return total ether value
        return uint256(ethPrice) * _ethAmount / 10 ** 20; //get from 8 decimals to 6
    }

    function _validBalanceProof(
        bytes calldata _validatorPubKey,
        uint256 _validatorBalance,
        bytes32 _balanceProof,
        uint256 _proofTimestamp
    ) internal returns (bool) {
        if (block.timestamp > _proofTimestamp + PROOF_EXPIRY_TIME) {
            return false;
        }
        //TODO check proof is valid
        return true;
    }
}
