// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "./StakeToken.sol";
import "./RewardToken.sol";

error stakingFailed();
error stakingWithdrawFailed();
error WithdrawTokenFailed();
error claimFailed();
error needMore();

contract StakingDapp {
    // can deposit token
    // can withdraw token
    // can stake token

    // you can transfer token to other address
    // has 1000000 tokens
    // 1 token = 0.001 ether
    IERC20 public stakeToken;
    IERC20 public rewardToken;

    uint256 public totalSupply;
    uint256 public stakeSupply;
    uint256 public rewardPerTokenStored;
    uint256 public constant REWARD_RATE = 100;
    uint256 public lastTimeStamp;

    mapping(address => uint256) public balanceOfToken;
    mapping(address => uint256) public stakeBalance;
    mapping(address => uint256) public userRewardPerToken;
    mapping(address => uint256) public rewards;

    constructor(address _rewardToken, address _stakeToken) {
        rewardToken = IERC20(_rewardToken);
        stakeToken = IERC20(_stakeToken);
        totalSupply = stakeToken.totalSupply();
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastTimeStamp = block.timestamp;
        rewards[account] = earned(account);
        userRewardPerToken[account] = rewardPerTokenStored;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert needMore();
        }
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (stakeSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastTimeStamp) * REWARD_RATE * 1e18) /
                stakeSupply);
    }

    function earned(address account) public view returns (uint256) {
        uint256 currentStakeBalance = stakeBalance[account];
        uint256 amountPaid = userRewardPerToken[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = rewards[account];

        uint256 _earned = ((currentStakeBalance *
            (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;
        return _earned;
    }

    function buyToken(uint256 _amount) public payable {
        uint256 ethAmount = _amount / 1000;
        require(_amount > 0);
        require(msg.value == ethAmount);
        balanceOfToken[msg.sender] += _amount;

        stakeToken.transfer(msg.sender, _amount);
    }

    function stake(uint256 _stakeAmount)
        public
        updateReward(msg.sender)
        moreThanZero(_stakeAmount)
    {
        require(balanceOfToken[msg.sender] >= _stakeAmount);
        balanceOfToken[msg.sender] -= _stakeAmount;
        stakeBalance[msg.sender] += _stakeAmount;
        stakeSupply += _stakeAmount;

        bool success = stakeToken.transferFrom(
            msg.sender,
            address(this),
            _stakeAmount
        );
        if (!success) {
            revert stakingFailed();
        }
    }

    function withdrawToken(uint256 amount) external moreThanZero(amount) {
        require(balanceOfToken[msg.sender] >= amount);
        balanceOfToken[msg.sender] -= amount;
        stakeBalance[msg.sender] -= amount;

        bool success = stakeToken.transferFrom(
            address(this),
            msg.sender,
            amount
        );
        if (!success) {
            revert WithdrawTokenFailed();
        }
    }

    function withdrawStakedToken(uint256 amount)
        external
        updateReward(msg.sender)
        moreThanZero(amount)
    {
        require(stakeBalance[msg.sender] >= amount);
        stakeBalance[msg.sender] -= amount;
        stakeSupply -= amount;
        bool success = stakeToken.transfer(msg.sender, amount);
        if (!success) {
            revert stakingWithdrawFailed();
        }
    }

    function claimReward() public updateReward(msg.sender) {
        uint256 claim = rewards[msg.sender];
        bool success = rewardToken.transfer(msg.sender, claim);
        if (!success) {
            revert claimFailed();
        }
    }

    /////////// GET FUNCTIONS ///////////

    function getStakedTokenBalance(address account)
        public
        view
        returns (uint256)
    {
        return stakeBalance[account];
    }

    function getTokenBalance(address account) public view returns (uint256) {
        return balanceOfToken[account];
    }

    function getStakeToken(address account) public view returns (uint256) {
        return stakeToken.balanceOf(account);
    }

    function getRewardToken(address account) public view returns (uint256) {
        return rewardToken.balanceOf(account);
    }

    function getContractETHBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
