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
    address payable public player;
    Utilities internal utils;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        player = users[0];

        stakeToken = new StakeToken();
        rewardToken = new RewardToken();
        stakingDapp = new StakingDapp(
            address(stakeToken),
            address(rewardToken)
        );
        stakeToken.approve(address(stakingDapp), 1000000 * 10**uint256(18));
        stakeToken.transfer(address(stakingDapp), 1000000 * 10**uint256(18));
        assertEq(
            stakeToken.balanceOf(address(stakingDapp)),
            1000000 * 10**uint256(18)
        );
        rewardToken.approve(address(stakingDapp), 1000000 * 10**uint256(18));
        rewardToken.transfer(address(stakingDapp), 1000000 * 10**uint256(18));
        assertEq(
            rewardToken.balanceOf(address(stakingDapp)),
            1000000 * 10**uint256(18)
        );
    }

    function testBuyToken() public {
        // buy

        stakingDapp.buyToken{value: 1 ether}(1000 * 10**uint256(18));
        assertEq(
            stakingDapp.getStakeToken(address(this)),
            1000 * 10**uint256(18)
        );
        assertEq(
            stakingDapp.balanceOfToken(address(this)),
            1000 * 10**uint256(18)
        );

        assertEq(stakingDapp.getContractETHBalance(), 1 ether);
    }

    function testWithdrawToken() public {
        // withdraw
        stakingDapp.buyToken{value: 1 ether}(1000 * 10**uint256(18));

        stakingDapp.withdrawToken(1000 * 10**uint256(18));

        assertEq(stakingDapp.balanceOfToken(address(this)), 0);
    }

    function testStake() public {
        stakingDapp.buyToken{value: 1 ether}(1000 * 10**uint256(18));

        stakingDapp.stake(1000 * 10**uint256(18));

        console.log(stakingDapp.getStakeToken(address(this)));

        uint256 startingEarned = stakingDapp.earned(address(this));
        console.log(startingEarned);

        skip(86400);
        vm.roll(1);

        uint256 endingEarned = stakingDapp.earned(address(this));
        console.log(endingEarned);
    }

    function testWithdrawStakedToken() public {
        stakingDapp.buyToken{value: 1 ether}(1000 * 10**uint256(18));

        stakingDapp.stake(1000 * 10**uint256(18));

        skip(86400);
        vm.roll(1);

        stakingDapp.withdrawStakedToken(1000 * 10**uint256(18));
        assertEq(stakingDapp.getStakedTokenBalance(address(this)), 0);
    }

    function testClaimRewards() public {
        stakingDapp.buyToken{value: 1 ether}(1000 * 10**uint256(18));

        stakingDapp.stake(1000 * 10**uint256(18));

        skip(86400);
        vm.roll(1);

        stakingDapp.claimReward();
        assertEq(
            stakingDapp.getRewardToken(address(this)),
            stakingDapp.earned(address(this))
        );
    }
}
