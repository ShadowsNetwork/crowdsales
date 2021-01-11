// SPDX-License-Identifier: MI

pragma solidity >=0.6.0 <0.8.0;

interface IVestingVault {
    function addTokenGrant(
        address _recipient,
        uint256 _amount,
        uint16 _vestingDurationInDays,
        uint16 _vestingCliffInDays    
    ) external; 

    function claimVestedTokens() external;

    function revokeTokenGrant(address _recipient) external;
}