// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    constructor() ERC20("RewardToken", "RT") {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        _mint(msg.sender, 1000000 * 10**uint256(decimals()));
    }
}
