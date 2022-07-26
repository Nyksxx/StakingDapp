// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Script.sol";
import "../src/StakingDapp.sol";
import "../src/StakeToken.sol";
import "../src/RewardToken.sol";

contract DeployStakingDapp is Script {
    RewardToken public rewardToken;
    StakeToken public stakeToken;
    StakingDapp public stakingDapp;

    function run() external {
        vm.startBroadcast();
        rewardToken = new RewardToken();
        stakeToken = new StakeToken();

        stakingDapp = new StakingDapp(
            address(stakeToken),
            address(rewardToken)
        );
        //rewardToken.transfer(address(stakingDapp), 1000000 * 10**uint256(18));
        //stakeToken.transfer(address(stakingDapp), 1000000 * 10**uint256(18));

        vm.stopBroadcast();
    }
}
