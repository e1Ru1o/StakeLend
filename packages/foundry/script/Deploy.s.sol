//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/YourContract.sol";
import "./DeployHelpers.s.sol";
import "../src/utils/mockUSDC.sol";
import "../src/StakeLend.sol";
import "../src/StakeVault.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    function run() external {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        vm.startBroadcast(deployerPrivateKey);
        // YourContract yourContract =
        //     new YourContract(vm.addr(deployerPrivateKey));
        // console.logString(
        //     string.concat(
        //         "YourContract deployed at: ", vm.toString(address(yourContract))
        //     )
        // );

        mockUSDC usdc = new mockUSDC();
        console.logString(
            string.concat("MockUSDC deployed at: ", vm.toString(address(usdc)))
        );

        StakeVault stakeVault = new StakeVault();
        console.logString(
            string.concat(
                "StakeVault deployed at: ", vm.toString(address(stakeVault))
            )
        );

        StakeLend stakeLend = new StakeLend(
            stakeVault,
            usdc,
            address(0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5)
        );
        console.logString(
            string.concat(
                "StakeLend deployed at: ", vm.toString(address(stakeLend))
            )
        );
        vm.stopBroadcast();

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }

    function test() public {}
}
