// SPDX-License-Identifier: MI

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract DOSToken is ERC20, ERC20Burnable {
    constructor(uint256 initialSupply) ERC20("Shadows Network Token", "DOS") {
        _mint(msg.sender, initialSupply);
    }
}