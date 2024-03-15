// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IStakeLend {
    event PoolCreated(address indexed pool, bytes32 indexed credentials);
    event PoolFilled(address indexed depositor, address indexed pool, uint256 indexed deposit);

    /**
     * Creates a pool for a validator
     * @param requiredAmount Amount of USDC to be lendend
     * @param credentials Credentials of the validator
     */
    function createPool(uint256 requiredAmount, bytes32 credentials) external returns (uint256 poolId);

    /**
     * Lenders can fill pools with assets
     * @dev If the deposit exeeds the required amount only the amount needed to fill the requirement is taken
     * @param poolId Id of the pool to fill/deposit assets into
     * @param depositAmount Amount of assets to add to the pool
     */
    function fillPool(uint256 poolId, uint256 depositAmount) external returns (uint256 depositedAmount);

    /**
     * @dev Required amount needs to be filled
     * @dev Shares becomes not redeamable
     * @dev Only owner of the pool can trigger it
     * @param poolId Id of the pool to lend from
     */
    function lend(uint256 poolId) external;

    /**
     * Lender can take back assets + profit
     * @dev Callet should have some shares in the pool
     * @dev Burns all the shares of the lender
     * @param poolId Pool to claim assets from
     */
    function claim(uint256 poolId) external;
}
