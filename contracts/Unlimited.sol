// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "./interfaces/IwNETT.sol";
import "./interfaces/IPadFactory.sol";

interface Ownable {
    function owner() external view returns (address);
}

/// @title Launchpad V2 Unlimited model
/// @author Netswap
/// @notice A launch contract enabling unlimited deposit and refunds(if any)
contract Unlimited {
    using SafeERC20Upgradeable for IERC20MetadataUpgradeable;
    using SafeMathUpgradeable for uint256;

    enum Phase {Prepare, Deposit, SaleEnded, Launch}

    struct UserInfo {
        /// @notice How much sale token user will get
        uint256 allocation;
        /// @notice How much payment token user has deposited for this launch event
        uint256 balance;
        /// @notice How much refunds user will get under situation of over-subscription
        uint256 refunds;
        /// @notice If user claimed refunds
        bool hasClaimedRefunds;
    }

    /// @notice Issuer of sale token
    address public issuer;

    /// @notice The start time of depositing
    uint256 public depositStart;
    uint256 public DEPOSIT_DURATION;

    /// @notice The start time of launching token
    uint256 public launchTime;

    /// @notice price in USD per sale token
    /// @dev price is scaled to 1e18
    uint256 public price;

    IwNETT public wNETT;
    uint256 public USDPerWNETT;
    IERC20MetadataUpgradeable public issuedToken;
    IERC20MetadataUpgradeable public paymentToken;
    uint256 public issuedTokenAmount;
    /// @notice target raised amount of payment token
    uint256 public targetRaised;
    uint256 public issuedTokenDecimals;
    uint256 public paymentTokenDecimals;
    uint256 public PRICE_DECIMALS;
    address[] public participants;

    IPadFactory public padFactory;

    bool public isWhitelist;
    bool public stopped;

    /// @dev paymentTokenReserve is the exact amount of paymentToken raised from users and needs to be kept inside the contract.
    /// If there is some excess (because someone sent token directly to the contract), the
    /// feeCollector can collect the excess using `skim()`
    uint256 private paymentTokenReserve;

    mapping(address => UserInfo) public getUserInfo;

    function initialize(
        address _issuer, 
        address _issuedToken, 
        address _paymentToken, 
        uint256 _issuedTokenAmount, 
        uint256 _price, 
        uint256 _depositStartTime, 
        uint256 _depositDuration, 
        uint256 _launchTime, 
        uint256 _decimals, 
        bool _isWhitelist
    ) external atPhase(Phase.Prepare) {
        require(depositStart == 0, "Unlimited: already initialized");

        padFactory = IPadFactory(msg.sender);
        wNETT = IwNETT(padFactory.wNETT());
        USDPerWNETT = padFactory.USDPerWNETT();

        require(
            _issuer != address(0),
            "Unlimited: issuer must be address zero"
        );
        require(
            _depositStartTime > block.timestamp, 
            "Unlimited: start of depositing can not be in the past"
        );

        issuer = _issuer;
        issuedToken = IERC20MetadataUpgradeable(_issuedToken);
        paymentToken = IERC20MetadataUpgradeable(_paymentToken);
        issuedTokenAmount = _issuedTokenAmount;
        price = _price;
        depositStart = _depositStartTime;
        DEPOSIT_DURATION =  _depositDuration;
        launchTime = _launchTime;
        issuedTokenDecimals = _decimals;
        paymentTokenDecimals = 1e6;
        PRICE_DECIMALS = 1e18;
        isWhitelist = _isWhitelist;
        targetRaised = issuedTokenAmount.mul(price)
            .mul(paymentTokenDecimals)
            .div(issuedTokenDecimals)
            .div(PRICE_DECIMALS);

        emit UnlimitedEventInitialized(
            issuedTokenAmount,
            price,
            targetRaised
        );
    }

    /// @notice Deposits payment token and burns wNETT
    function depoist(uint256 amount) 
        external 
        isStopped(false) 
        atPhase(Phase.Deposit) 
    {
        require(
            amount > 0,
            "Unlimited: expected non-zero payment token to deposit"
        );

        UserInfo storage user = getUserInfo[msg.sender];
        uint256 newBalance = user.balance + amount;

        uint256 wNETTNeeded = getWNETTNeeded(amount);
        require(wNETT.balanceOf(msg.sender) >= wNETTNeeded, "Unlimited: Not enough wNETT to burn");

        user.balance = newBalance;
        paymentTokenReserve += amount;

        if(wNETTNeeded > 0) {
            wNETT.burnFrom(msg.sender, wNETTNeeded);
        }

        if (user.balance == 0) {
            participants.push(msg.sender);
        }

        paymentToken.transferFrom(msg.sender, address(this), amount);

        emit UserParticipated(msg.sender, amount, wNETTNeeded);
    }

    function refund() external hasRefunds {
        require(
            currentPhase() == Phase.SaleEnded || currentPhase() == Phase.Launch, 
            "Unlimited: Wrong phase"
        );
        UserInfo storage user = getUserInfo[msg.sender];
        uint256 refundsAmount = getUserRefunds(msg.sender);
        user.refunds = refundsAmount;
        user.hasClaimedRefunds = true;
        _safeTransferPaymentToken(msg.sender, refundsAmount);
        emit UserRefunds(msg.sender, user.balance, refundsAmount);
    }

    /// @notice Auto set allocation for all participants
    function autoSetAlloc() external {
        require( 
            msg.sender == Ownable(address(padFactory)).owner(),
            "Unlimited: caller is not PadFactory owner"
        );
        require(
            currentPhase() == Phase.SaleEnded || currentPhase() == Phase.Launch, 
            "Unlimited: Wrong phase"
        );
        for (uint256 index = 0; index < userCount(); index++) {
            UserInfo storage user = getUserInfo[participants[index]];
            user.allocation = getUserAllocation(participants[index]);
        }
    }

    /// @notice Manually set allocation for participants in case of auto set "out of gas"
    /// @param _start the index starts from to set
    /// @param _end the index ends to set
    function manullySetAlloc(uint256 _start, uint256 _end) external {
        require( 
            msg.sender == Ownable(address(padFactory)).owner(),
            "Unlimited: caller is not PadFactory owner"
        );
        require(
            currentPhase() == Phase.SaleEnded || currentPhase() == Phase.Launch, 
            "Unlimited: Wrong phase"
        );
        for (uint256 index = _start; index < _end; index++) {
            UserInfo storage user = getUserInfo[participants[index]];
            user.allocation = getUserAllocation(participants[index]);
        }
    }

    function getAllUsers() public view returns (address[] memory) {
        return participants;
    }
    
    function userCount() public view returns (uint256) {
        return participants.length;
    }

    function getAllUserInfo() public view returns (UserInfo[] memory) {
        UserInfo[] memory userInfo = new UserInfo[](userCount());
        for (uint256 index = 0; index < userCount(); index++) {
            userInfo[index] = getUserInfo[participants[index]];
        }
        return userInfo;
    }

    /// @notice The current phase the event is in
    function currentPhase() public view returns (Phase) {
        if (depositStart == 0 || block.timestamp < depositStart) {
            return Phase.Prepare;
        } else if (block.timestamp < depositStart + DEPOSIT_DURATION) {
            return Phase.Deposit;
        } else if (
            block.timestamp >= depositStart + DEPOSIT_DURATION &&
            block.timestamp < launchTime
        ) {
            return Phase.SaleEnded;
        }
        return Phase.Launch;
    }

    function getUserAllocation(address _user) public view returns (uint256) {
        UserInfo storage user = getUserInfo[_user];
        (,uint256 issuerCharged,,) = getFundsDistribution();
        uint256 actualSaledTokenAmount = issuedTokenAmount.mul(issuerCharged).div(targetRaised);
        uint256 userAllocation = actualSaledTokenAmount.mul(user.balance).div(paymentTokenReserve);
        return userAllocation;
    }

    function getUserRefunds(address _user) public view returns (uint256) {
        UserInfo storage user = getUserInfo[_user];
        (,,, uint256 refunds) = getFundsDistribution();
        uint256 userRefunds = 0;
        if (refunds > 0) {
            userRefunds = refunds.mul(user.balance).div(paymentTokenReserve);
        }
        return userRefunds;
    }

    function getFundsDistribution() public view returns (
        uint256 totalRaised, 
        uint256 issuerCharged, 
        uint256 fees, 
        uint256 refunds
    ) {
        totalRaised = paymentTokenReserve;
        IPadFactory.Multiplier memory multiplier = padFactory.multiplier();
        uint256 feeRate = padFactory.multiplierFeeRate(0);
        if (totalRaised > targetRaised.mul(multiplier.multiplier100).div(10)) {
            feeRate = padFactory.multiplierFeeRate(multiplier.multiplier100);
        } else if (totalRaised > targetRaised.mul(multiplier.multiplier50).div(10)) {
            feeRate = padFactory.multiplierFeeRate(multiplier.multiplier50);
        } else if (totalRaised > targetRaised.mul(multiplier.multiplier25).div(10)) {
            feeRate = padFactory.multiplierFeeRate(multiplier.multiplier25);
        } else if (totalRaised > targetRaised.mul(multiplier.multiplier20).div(10)) {
            feeRate = padFactory.multiplierFeeRate(multiplier.multiplier20);
        } else if (totalRaised > targetRaised.mul(multiplier.multiplier15).div(10)) {
            feeRate = padFactory.multiplierFeeRate(multiplier.multiplier15);
        } else if (totalRaised > targetRaised.mul(multiplier.multiplier10).div(10)) {
            feeRate = padFactory.multiplierFeeRate(multiplier.multiplier10);
        }
        uint256 tmpFees = targetRaised.mul(feeRate).div(10000);
        if (tmpFees.add(targetRaised) > totalRaised) {
            fees = totalRaised.mul(feeRate).div(10000);
        } else {
            fees = tmpFees;
        }
        issuerCharged = totalRaised.sub(fees);
        if (issuerCharged > targetRaised) {
            issuerCharged = targetRaised;
        }
        refunds = totalRaised.sub(issuerCharged).sub(fees);
    }

    /// @notice Get the wNETT amount needed to deposit payment token
    /// @param _paymentTokenAmount The amount of payment token to deposit
    /// @return The amount of wNETT needed
    function getWNETTNeeded(uint256 _paymentTokenAmount) public view returns (uint256) {
        return _paymentTokenAmount.mul(1e18).div(USDPerWNETT);
    }

    /// @notice Force balances to match tokens that were deposited, but not sent directly to the contract.
    /// Any excess tokens are sent to the feeCollector
    function skim() external {
        require(msg.sender == tx.origin, "Unlimited: EOA only");
        address feeCollector = padFactory.feeCollector();

        uint256 excessPaymentToken = paymentToken.balanceOf(address(this)) - paymentTokenReserve;
        if (excessPaymentToken > 0) {
            _safeTransferPaymentToken(feeCollector, excessPaymentToken);
        }
    }

    /// @notice Withdraw payment token if launch has been cancelled
    function emergencyWithdraw() external isStopped(true) {
        UserInfo storage user = getUserInfo[msg.sender];
        require(
            user.balance > 0,
            "Unlimited: expected user to have non-zero balance to perform emergency withdraw"
        );

        uint256 balance = user.balance;
        user.balance = 0;
        paymentTokenReserve -= balance;

        _safeTransferPaymentToken(msg.sender, balance);

        emit PaymentTokenEmergencyWithdraw(msg.sender, balance);
    }

    /// @notice Stops the launch event and allows participants to withdraw deposits
    function allowEmergencyWithdraw() external {
        require(
            msg.sender == Ownable(address(padFactory)).owner(),
            "Unlimited: caller is not PadFactory owner"
        );
        stopped = true;
        emit Stopped();
    }

    /* ========== MODIFIER ========== */

    /// @notice Modifier which ensures contract is in a defined phase
    modifier atPhase(Phase _phase) {
        _atPhase(_phase);
        _;
    }

    /// @notice Ensures launch event is stopped/running
    modifier isStopped(bool _stopped) {
        _isStopped(_stopped);
        _;
    }

    modifier hasRefunds() {
        (,,, uint256 refunds) = getFundsDistribution();
        require(refunds > 0, "Unlimited: no refunds");
        _;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    /// @dev Bytecode size optimization for the `atPhase` modifier
    /// This works becuase internal functions are not in-lined in modifiers
    function _atPhase(Phase _phase) internal view {
        require(currentPhase() == _phase, "Unlimited: wrong phase");
    }

    /// @dev Bytecode size optimization for the `isStopped` modifier
    /// This works becuase internal functions are not in-lined in modifiers
    function _isStopped(bool _stopped) internal view {
        if (_stopped) {
            require(stopped, "Unlimited: is still running");
        } else {
            require(!stopped, "Unlimited: stopped");
        }
    }

    /// @notice Send Payment Token
    /// @param _to The receiving address
    /// @param _value The amount of payment token to send
    /// @dev Will revert on failure
    function _safeTransferPaymentToken(address _to, uint256 _value) internal {
        require(
            paymentToken.balanceOf(address(this)) >= paymentTokenReserve,
            "Unlimited: not enough payment token"
        );
        paymentToken.transfer(_to, _value);
    }

    /* ========== EVENTS ========== */
    event UnlimitedEventInitialized(
        uint256 issuedTokenAmount,
        uint256 price,
        uint256 targetRaised
    );

    event UserParticipated(
        address indexed user,
        uint256 paidAmount,
        uint256 wNETTAmount
    );

    event UserRefunds(
        address indexed user,
        uint256 paidAmount,
        uint256 refunds
    );

    event Stopped();

    event PaymentTokenEmergencyWithdraw(address indexed user, uint256 amount);

    event IssuedTokenEmergencyWithdraw(address indexed user, uint256 amount);

}