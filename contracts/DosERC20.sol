pragma solidity ^0.5.16;

import "./interfaces/IERC20.sol";
import "./ExternStateToken.sol";
import "./TokenState.sol";
import "./SafeDecimalMath.sol";

contract DosERC20 is IERC20, ExternStateToken {

    string public constant TOKEN_NAME = "Shadows Network Token";
    string public constant TOKEN_SYMBOL = "DOS";
    uint8 public constant DECIMALS = 18;
    uint public constant TOTAL_SUPPLY = 100000000;
    bool internal isInit = false;

    constructor(
        address payable _proxy,
        TokenState _tokenState,
        address _owner
    )
        public
        ExternStateToken(_proxy, _tokenState, TOKEN_NAME, TOKEN_SYMBOL, TOTAL_SUPPLY, DECIMALS, _owner)
    {}

    function init() external onlyOwner returns (bool) {
        require(!isInit, "inited");
        uint total = TOTAL_SUPPLY * SafeDecimalMath.unit();
        tokenState.setBalanceOf(msg.sender, tokenState.balanceOf(msg.sender).add(total));
        emitTransfer(address(this), msg.sender, total);
        isInit = true;
    }

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
