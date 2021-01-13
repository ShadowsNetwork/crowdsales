// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IVestingVault.sol";

contract VestingVault is IVestingVault, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint16;
    using SafeERC20 for IERC20;

    struct Grant {
        uint256 amount;
        uint16 vestingDuration;
        uint16 daysClaimed;
        uint256 totalClaimed;
        address recipient;
    }

    event GrantAdded(address indexed recipient);
    event GrantTokensClaimed(address indexed recipient, uint256 amountClaimed);
    event GrantRevoked(
        address recipient,
        uint256 amountVested,
        uint256 amountNotVested
    );

    IERC20 public token;

    mapping(address => Grant) private tokenGrants;

    uint256 public totalVestingCount;

    uint256 public claimBeginTime = 0;

    address public tokenWallet;

    address public associateContract;

    constructor() {}

    function setToken(address _token) public onlyOwner returns (bool) {
        require(address(_token) != address(0));
        token = IERC20(_token);
        return true;
    }

    function setClaimBeginTime(uint256 _claimBeginTime) public onlyOwner returns (bool) {
        require(_claimBeginTime != 0);
        claimBeginTime = _claimBeginTime;
        return true;
    }

    function setTokenWallet(address _tokenWallet)
        public
        onlyOwner
        returns (bool)
    {
        require(address(_tokenWallet) != address(0));
        tokenWallet = _tokenWallet;
        return true;
    }

    function setAssociateContract(address _associateContract)
        public
        onlyOwner
        returns (bool)
    {
        require(
            _associateContract != address(0),
            "associateContract is the zero address"
        );
        associateContract = _associateContract;
        return true;
    }

    function addTokenGrant(
        address _recipient,
        uint256 _amount,
        uint16 _vestingDurationInDays,
        uint16 _vestingCliffInDays
    ) external override onlyOwnerOrAssociateContract {
        require(
            tokenGrants[_recipient].amount == 0,
            "Grant already exists, must revoke first."
        );
        require(_vestingCliffInDays <= 10 * 365, "Cliff greater than 10 years");
        require(
            _vestingDurationInDays <= 25 * 365,
            "Duration greater than 25 years"
        );

        uint256 amountVestedPerDay = _amount.div(_vestingDurationInDays);
        require(amountVestedPerDay > 0, "amountVestedPerDay > 0");

        // Transfer the grant tokens under the control of the vesting contract
        // require(token.transferFrom(owner(), address(this), _amount));

        Grant memory grant =
            Grant({
                amount: _amount,
                vestingDuration: _vestingDurationInDays,
                daysClaimed: 0,
                totalClaimed: 0,
                recipient: _recipient
            });
        tokenGrants[_recipient] = grant;
        emit GrantAdded(_recipient);
    }

    /// @notice Allows a grant recipient to claim their vested tokens. Errors if no tokens have vested
    function claimVestedTokens() external override {
        require(
            claimBeginTime > 0 && currentTime() >= claimBeginTime,
            "claim has not yet started"
        );
        uint16 daysVested;
        uint256 amountVested;
        (daysVested, amountVested) = calculateGrantClaim(msg.sender);
        require(amountVested > 0, "Vested is 0");

        Grant storage tokenGrant = tokenGrants[msg.sender];
        tokenGrant.daysClaimed = uint16(tokenGrant.daysClaimed.add(daysVested));
        tokenGrant.totalClaimed = uint256(
            tokenGrant.totalClaimed.add(amountVested)
        );

        token.safeTransferFrom(tokenWallet, tokenGrant.recipient, amountVested);
        emit GrantTokensClaimed(tokenGrant.recipient, amountVested);
    }

    /// @notice Terminate token grant transferring all vested tokens to the `_recipient`
    /// and returning all non-vested tokens to the contract owner
    /// Secured to the contract owner only
    /// @param _recipient address of the token grant recipient
    function revokeTokenGrant(address _recipient) external override onlyOwner {
        Grant storage tokenGrant = tokenGrants[_recipient];
        uint16 daysVested;
        uint256 amountVested;
        (daysVested, amountVested) = calculateGrantClaim(_recipient);

        uint256 amountNotVested =
            (tokenGrant.amount.sub(tokenGrant.totalClaimed)).sub(amountVested);

        require(token.transfer(owner(), amountNotVested));
        require(token.transfer(_recipient, amountVested));

        tokenGrant.amount = 0;
        tokenGrant.vestingDuration = 0;
        tokenGrant.daysClaimed = 0;
        tokenGrant.totalClaimed = 0;
        tokenGrant.recipient = address(0);

        emit GrantRevoked(_recipient, amountVested, amountNotVested);
    }


    function getGrantAmount(address _recipient) public view returns (uint256) {
        Grant storage tokenGrant = tokenGrants[_recipient];
        return tokenGrant.amount;
    }

    /// @notice Calculate the vested and unclaimed months and tokens available for `_grantId` to claim
    /// Due to rounding errors once grant duration is reached, returns the entire left grant amount
    /// Returns (0, 0) if cliff has not been reached
    function calculateGrantClaim(address _recipient)
        public
        view
        returns (uint16, uint256)
    {
        Grant storage tokenGrant = tokenGrants[_recipient];

        require(
            tokenGrant.totalClaimed < tokenGrant.amount,
            "Grant fully claimed"
        );

        // For grants created with a future start date, that hasn't been reached, return 0, 0
        if (claimBeginTime == 0 || currentTime() < claimBeginTime) {
            return (0, 0);
        }

        // Check cliff was reached
        uint256 elapsedDays =
            currentTime().sub(claimBeginTime - 1 days).div(1 days);

        // If over vesting duration, all tokens vested
        if (elapsedDays >= tokenGrant.vestingDuration) {
            uint256 remainingGrant =
                tokenGrant.amount.sub(tokenGrant.totalClaimed);
            return (tokenGrant.vestingDuration, remainingGrant);
        } else {
            uint16 daysVested = uint16(elapsedDays.sub(tokenGrant.daysClaimed));
            uint256 amountVestedPerDay =
                tokenGrant.amount.div(uint256(tokenGrant.vestingDuration));
            uint256 amountVested = uint256(daysVested.mul(amountVestedPerDay));
            return (daysVested, amountVested);
        }
    }

    function currentTime() private view returns (uint256) {
        return block.timestamp;
    }

    modifier onlyOwnerOrAssociateContract() {
        require(
            owner() == _msgSender() || _msgSender() == associateContract,
            "Ownable: caller is not the owner"
        );
        _;
    }
}
