pragma solidity ^0.5.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract DOSToken is ERC20, ERC20Detailed, ERC20Burnable {
    constructor(uint256 initialSupply) ERC20Detailed("Shadows Network Token", "DOS", 18) public {
        _mint(msg.sender, initialSupply);
    }
}