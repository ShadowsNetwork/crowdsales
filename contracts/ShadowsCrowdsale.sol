pragma solidity ^0.5.5;

import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import "@openzeppelin/contracts/crowdsale/emission/AllowanceCrowdsale.sol";

contract ShadowsCrowdsale is Crowdsale, AllowanceCrowdsale {
    constructor(
        uint256 rate,
        address payable wallet,
        IERC20 token,
        address tokenWallet
    )
        AllowanceCrowdsale(tokenWallet)
        Crowdsale(rate, wallet, token)
        public
    {

    }
}