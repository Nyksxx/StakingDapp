// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Script.sol";

import "../src/StakeToken.sol";

contract DeployStakeToken is Script {
    StakeToken public stakeToken;

    function run() external {
        vm.startBroadcast();

        stakeToken = new StakeToken();

        vm.stopBroadcast();
    }
}
