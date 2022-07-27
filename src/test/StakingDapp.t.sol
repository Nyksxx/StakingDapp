// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../StakingDapp.sol";
import "../StakeToken.sol";
import "../RewardToken.sol";
import "./utils/Cheats.sol";
import "forge-std/Test.sol";
import "./utils/Utilities.sol";

contract StakingDappTest is Test {
    StakingDapp public stakingDapp;
    StakeToken public stakeToken;
    RewardToken public rewardToken;
    address public account;
    Utilities internal utils;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        account = users[0];

        stakeToken = new StakeToken();
        rewardToken = new RewardToken();
        stakingDapp = new StakingDapp(
            address(stakeToken),
            address(rewardToken)
        );
        stakeToken.transfer(address(stakingDapp), 1000000 * 10**uint256(18));
        assertEq(
            stakeToken.balanceOf(address(stakingDapp)),
            1000000 * 10**uint256(18)
        );
        rewardToken.transfer(address(stakingDapp), 1000000 * 10**uint256(18));
        assertEq(
            rewardToken.balanceOf(address(stakingDapp)),
            1000000 * 10**uint256(18)
        );
    }

    function testBuy() public {
        // buy
    }
}