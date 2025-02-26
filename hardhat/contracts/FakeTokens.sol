// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeToken is ERC20 {
    constructor() ERC20("FakeToken", "FTK") {
        _mint(msg.sender, 1000000 * 10 ** 18); // Mint 1M tokens to deployer
    }

    function faucet(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
