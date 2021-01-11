pragma solidity ^0.5.16;

interface IVestingVault {
    function addTokenGrant(
        address _recipient,
        uint256 _amount,
        uint16 _vestingDurationInDays,
        uint16 _vestingCliffInDays    
    ); 

    function claimVestedTokens() external;

    function revokeTokenGrant(address _recipient) external;

    function getGrantStartTime(address _recipient) public view returns(uint256);

    function getGrantAmount(address _recipient) public view returns(uint256);

    function getGrantAmount(address _recipient) public view returns(uint256);
}