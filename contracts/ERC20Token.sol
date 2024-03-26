// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CUSDToken is ERC20 {
    constructor() ERC20("Custom USD Coin", "cUSD") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}
