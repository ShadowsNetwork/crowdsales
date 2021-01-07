pragma solidity ^0.5.16;

import "./interfaces/IERC20.sol";
import "./ExternStateToken.sol";
import "./TokenState.sol";


contract DosERC20 is IERC20, ExternStateToken {

    string public constant TOKEN_NAME = "Shadows Network Token";
    string public constant TOKEN_SYMBOL = "DOS";
    uint8 public constant DECIMALS = 18;

    constructor(
        address payable _proxy,
        TokenState _tokenState,
        address _owner,
        uint _totalSupply
    )
        public
        ExternStateToken(_proxy, _tokenState, TOKEN_NAME, TOKEN_SYMBOL, _totalSupply, DECIMALS, _owner)
    {}


    function transfer(address to, uint value) external optionalProxy returns (bool) {
        _transferByProxy(messageSender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint value
    ) external optionalProxy returns (bool) {
        return _transferFromByProxy(messageSender, from, to, value);
    }
}
