// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./wNETT.sol";

/// @title wNETT Staking
/// @author Netswap
/// @notice Stake NETT to earn wNETT
contract wNETTStaking is Initializable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct UserInfo {
        uint256 amount; // How many NETT tokens the user has provided
        uint256 rewardDebt; // Reward debt. See explanation below
        //
        // We do some fancy math here. Basically, any point in time, the amount of NETTs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * accWNETTPerShare) / PRECISION - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. `accWNETTPerShare` (and `lastRewardTimestamp`) gets updated
        //   2. User receives the pending reward sent to his/her address
        //   3. User's `amount` gets updated
        //   4. User's `rewardDebt` gets updated
    }

    IERC20Upgradeable public nett;
    uint256 public lastRewardTimestamp;

    /// @dev Accumulated wNETT per share, times PRECISION. See above
    uint256 public accWNETTPerShare;
    /// @notice Precision of accWNETTPerShare
    uint256 private PRECISION;

    /// @dev The maximum emission rate per second
    uint256 public MAX_EMISSION_RATE;

    wNETT public wnett;
    uint256 public wNETTPerSec;

    /// @dev Balance of NETT held by contract
    uint256 public totalNETTStaked;

    /// @dev Info of each user that stakes NETT
    mapping(address => UserInfo) public userInfo;

    /// @notice Initialize with needed parameters
    /// @param _nett Address of the NETT token contract
    /// @param _wnett Address of the wNETT token contract
    /// @param _wNETTPerSec Number of wNETT tokens created per second
    /// @param _startTime Timestamp at which wNETT rewards starts
    function initialize(
        IERC20Upgradeable _nett,
        wNETT _wnett,
        uint256 _wNETTPerSec,
        uint256 _startTime
    ) external initializer {
        __Ownable_init();

        require(
            _startTime > block.timestamp,
            "wNETTStaking: wNETT minting needs to start after the current timestamp"
        );

        PRECISION = 1e18;
        MAX_EMISSION_RATE = 1e24;
        require(
            _wNETTPerSec <= MAX_EMISSION_RATE,
            "wNETTStaking: emission rate too high"
        );
        nett = _nett;
        wnett = _wnett;
        wNETTPerSec = _wNETTPerSec;
        lastRewardTimestamp = _startTime;
    }

    /// @notice Get pending wNETT for a given `_user`
    /// @param _user The user to lookup
    /// @return The number of pending wNETT tokens for `_user`
    function pendingWNETT(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        uint256 nettSupply = totalNETTStaked;
        uint256 _accWNETTPerShare = accWNETTPerShare;

        if (block.timestamp > lastRewardTimestamp && nettSupply != 0) {
            uint256 multiplier = block.timestamp - lastRewardTimestamp;
            uint256 wNETTReward = multiplier * wNETTPerSec;
            _accWNETTPerShare += (wNETTReward * PRECISION) / nettSupply;
        }
        return (user.amount * _accWNETTPerShare) / PRECISION - user.rewardDebt;
    }

    /// @notice Deposit nett to wNETTStaking for wNETT allocation
    /// @param _amount Amount of NETT to deposit
    function deposit(uint256 _amount) external {
        UserInfo storage user = userInfo[msg.sender];

        updatePool();

        uint256 pending;
        if (user.amount > 0) {
            pending =
                (user.amount * accWNETTPerShare) /
                PRECISION -
                user.rewardDebt;
        }
        user.amount += _amount;
        user.rewardDebt = (user.amount * accWNETTPerShare) / PRECISION;
        totalNETTStaked += _amount;

        if (_amount != 0)
            nett.safeTransferFrom(msg.sender, address(this), _amount);
        if (pending != 0) _safeWNETTTransfer(msg.sender, pending);
        emit Deposit(msg.sender, _amount);
    }

    /// @notice Withdraw NETT and accumulated wNETT from wNETTStaking
    /// @param _amount Amount of NETT to withdraw
    function withdraw(uint256 _amount) external {
        UserInfo storage user = userInfo[msg.sender];
        require(
            user.amount >= _amount,
            "wNETTStaking: withdraw amount exceeds balance"
        );

        updatePool();

        uint256 pending = (user.amount * accWNETTPerShare) /
            PRECISION -
            user.rewardDebt;

        user.amount -= _amount;
        user.rewardDebt = (user.amount * accWNETTPerShare) / PRECISION;

        if (pending > 0) _safeWNETTTransfer(msg.sender, pending);
        totalNETTStaked -= _amount;
        nett.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY
    function emergencyWithdraw() external {
        UserInfo storage user = userInfo[msg.sender];

        uint256 _amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        totalNETTStaked -= _amount;
        nett.safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(msg.sender, _amount);
    }

    /// @notice Update emission rate
    /// @param _wNETTPerSec The new value for wNETTPerSec
    function updateEmissionRate(uint256 _wNETTPerSec) external onlyOwner {
        require(
            _wNETTPerSec <= MAX_EMISSION_RATE,
            "wNETTStaking: emission rate too high"
        );
        updatePool();
        wNETTPerSec = _wNETTPerSec;
        emit UpdateEmissionRate(msg.sender, _wNETTPerSec);
    }

    /// @notice Update reward variables of the given pool with latest data
    function updatePool() public {
        if (block.timestamp <= lastRewardTimestamp) {
            return;
        }
        uint256 nettSupply = totalNETTStaked;
        if (nettSupply == 0) {
            lastRewardTimestamp = block.timestamp;
            return;
        }
        uint256 multiplier = block.timestamp - lastRewardTimestamp;
        uint256 wNETTReward = multiplier * wNETTPerSec;
        accWNETTPerShare += (wNETTReward * PRECISION) / nettSupply;
        lastRewardTimestamp = block.timestamp;

        wnett.mint(address(this), wNETTReward);
    }

    /// @notice Safe wNETT transfer function, just in case if rounding error causes pool to not have enough wNETTs
    /// @param _to Address that wil receive wNETT
    /// @param _amount The amount to send
    function _safeWNETTTransfer(address _to, uint256 _amount) internal {
        uint256 wNETTBal = wnett.balanceOf(address(this));
        if (_amount > wNETTBal) {
            IERC20Upgradeable(address(wnett)).safeTransfer(_to, wNETTBal);
        } else {
            IERC20Upgradeable(address(wnett)).safeTransfer(_to, _amount);
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */
    function setPadFactory(IPadFactory _padFactory) public onlyOwner {
        wnett.setPadFactory(_padFactory);
    }

    /* ========== EVENTS ========== */
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event UpdateEmissionRate(address indexed user, uint256 _wNETTPerSec);
}