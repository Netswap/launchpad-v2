
// File: contracts/interfaces/IPadFactory.sol



pragma solidity 0.8.6;

interface IPadFactory {
    struct Multiplier {
        uint256 multiplier10;
        uint256 multiplier15;
        uint256 multiplier20;
        uint256 multiplier25;
        uint256 multiplier50;
        uint256 multiplier100;
    }
    function wNETT() external view returns (address);
    function USDPerWNETT() external view returns (uint256);
    function feeCollector() external view returns (address);
    function multiplierFeeRate(uint256) external view returns (uint256);
    function multiplier() external view returns (Multiplier memory);
    function numModels() external view returns (uint256 total, uint256 primary, uint256 unlimited);
    function allUnlimitedModels(uint256 index) external view returns (address);
}
// File: contracts/interfaces/IwNETT.sol



pragma solidity 0.8.6;

interface IwNETT {
    /**
     * @dev Destroys `amount` tokens from `from`.
     *
     * See {ERC20-_burn}.
     */
    function burnFrom(address from, uint256 amount) external;
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
}
// File: @openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: contracts/Unlimited.sol


pragma solidity ^0.8.6;






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
    /// @notice min deposit amount user invest from, scaled to 1e6
    uint256 public minDeposit;
    uint256 public issuedTokenDecimals;
    uint256 public paymentTokenDecimals;
    uint256 public PRICE_DECIMALS;
    uint256 public accIssuerCharged;
    address[] public participants;

    IPadFactory public padFactory;

    bool public hasFeeCharged;
    bool public stopped;

    /// @dev paymentTokenReserve is the exact amount of paymentToken raised from users and needs to be kept inside the contract.
    /// If there is some excess (because someone sent token directly to the contract), the
    /// feeCollector can collect the excess using `skim()`
    uint256 public paymentTokenReserve;

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
        uint256 _minDeposit
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
        targetRaised = issuedTokenAmount.mul(price)
            .mul(paymentTokenDecimals)
            .div(issuedTokenDecimals)
            .div(PRICE_DECIMALS);
        minDeposit = _minDeposit;

        emit UnlimitedEventInitialized(
            issuedTokenAmount,
            price,
            targetRaised
        );
    }

    /// @notice Deposits payment token and burns wNETT
    function deposit(uint256 amount) 
        external 
        isStopped(false) 
        atPhase(Phase.Deposit) 
    {
        require(
            amount > 0,
            "Unlimited: expected non-zero payment token to deposit"
        );

        UserInfo storage user = getUserInfo[msg.sender];

        // first deposit
        if (user.balance == 0) {
            require(amount >= minDeposit, "Unlimited: must reach min deposit");
            participants.push(msg.sender);
        }

        uint256 newBalance = user.balance + amount;

        uint256 wNETTNeeded = getWNETTNeeded(amount);
        require(wNETT.balanceOf(msg.sender) >= wNETTNeeded, "Unlimited: Not enough wNETT to burn");

        user.balance = newBalance;
        paymentTokenReserve += amount;

        if(wNETTNeeded > 0) {
            wNETT.burnFrom(msg.sender, wNETTNeeded);
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
        require(!user.hasClaimedRefunds, "Unlimited: already claimed refunds");
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
        uint256 userAllocation = paymentTokenReserve > 0 ? actualSaledTokenAmount.mul(user.balance).div(paymentTokenReserve) : 0;
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

    function chargeRaised(uint256 _amount) external atPhase(Phase.SaleEnded) isStopped(false) {
        require(msg.sender == issuer, "Unlimited: only issuer can do this");
        (,uint256 issuerCharged,,) = getFundsDistribution();
        require(_amount.add(accIssuerCharged) <= issuerCharged, "Unlimited: Overflow");
        accIssuerCharged = _amount.add(accIssuerCharged);
        _safeTransferPaymentToken(msg.sender, _amount);
        emit IssuerChargedRaised(msg.sender, _amount, accIssuerCharged);
    }

    function chargeFees() external atPhase(Phase.SaleEnded) isStopped(false) {
        require(
            msg.sender == Ownable(address(padFactory)).owner(), 
            "Unlimited: not padFactory owner"
        );
        require(!hasFeeCharged, "Unlimited: fees has been charged");
        (,,uint256 fees,) = getFundsDistribution();
        hasFeeCharged = true;
        _safeTransferPaymentToken(msg.sender, fees);
        emit FeeCharged(msg.sender, fees);
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

    function updateDepositDuration(uint256 _newDuration) atPhase(Phase.Deposit) external {
        require(
            msg.sender == Ownable(address(padFactory)).owner(),
            "Unlimited: caller is not PadFactory owner"
        );
        require(depositStart + _newDuration > block.timestamp, "invalid");
        DEPOSIT_DURATION = _newDuration;
    }

    function updateLaunchTime(uint256 _newLaunchTime) atPhase(Phase.SaleEnded) external {
        require(
            msg.sender == Ownable(address(padFactory)).owner(),
            "Unlimited: caller is not PadFactory owner"
        );
        require(_newLaunchTime > block.timestamp, "invalid");
        launchTime = _newLaunchTime;
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
        uint256 paymentBal = paymentToken.balanceOf(address(this));
        if (_value > paymentBal) {
            paymentToken.transfer(_to, paymentBal);
        } else {
            paymentToken.transfer(_to, _value);
        }
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

    event IssuerChargedRaised(address indexed issuer, uint256 amount, uint256 accAmount);

    event FeeCharged(address indexed user, uint256 fees);
}