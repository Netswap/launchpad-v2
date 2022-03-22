// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./interfaces/IPrimary.sol";
import "./interfaces/IUnlimited.sol";

contract PadFactory is Initializable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public feeCollector;
    address public primaryImplementation;
    address public unlimitedImplementation;
    address public wNETT;
    // 1 wNETT equals to how much USD, scaled to 1e6
    uint256 public USDPerWNETT;

    // issued token => model address
    mapping(address => address) public getModel;
    mapping(address => bool) public isModel;
    // fee rates of unlimited model
    mapping(uint256 => uint256) public multiplierFeeRate;
    address[] public allPrimaryModels;
    address[] public allUnlimitedModels;

    /// @notice initializes the pad factory
    /// @dev Uses clone factory pattern to save space
    /// @param _primaryImplementation Implementation of primary model contract
    /// @param _unlimitedImplementation Implementation of unlimited model contract
    /// @param _wNETT wNETT token address
    /// @param _feeCollector Address that collects participation fees of unlimited model
    function initialize(
        address _primaryImplementation,
        address _unlimitedImplementation,
        address _wNETT,
        address _feeCollector
    ) public initializer {
        __Ownable_init();

        require(
            _primaryImplementation != address(0) && _unlimitedImplementation != address(0),
            "PadFactory: model implentation can't be zero address"
        );
        require(_wNETT != address(0), "PadFactory: wNETT can't be zero address");
        require(_feeCollector != address(0), "PadFactory: fee collector can't be zero address");
        
        primaryImplementation = _primaryImplementation;
        unlimitedImplementation = _unlimitedImplementation;
        wNETT = _wNETT;
        feeCollector = _feeCollector;
        USDPerWNETT = 6e6;

        _setDefaultFeeRate();
    }

    /// @notice Returns the number of models
    function numModels() external view returns (uint256 total, uint256 primary, uint256 unlimited) {
        total = allPrimaryModels.length + allUnlimitedModels.length;
        primary = allPrimaryModels.length;
        unlimited = allUnlimitedModels.length;
    }

    /// @notice Creates a primary model contract
    /// @param _issuer Address of the project issuing tokens for auction
    /// @param _issuedToken Token that will be issued through this launch event
    /// @param _paymentToken Token that will be raised through this launch event
    /// @param _issuedTokenAmount Amount of tokens that will be issued
    /// @param _price Price of each token in USD, scaled to 1e18
    /// @param _maxAllocPerUser Maximum number of stablecoin each participant can commit
    /// @param _depositStartTime Timestamp of when launch event will start to deposit
    /// @param _depositDuration Timestamp of how long deposit phase will last for
    /// @param _launchTime Timestamp of when launch event will launch token
    /// @param _decimals Decimals of issuedToken
    /// @return Address of primary model launch event contract
    function createNewPrimaryModel(
        address _issuer,
        address _issuedToken,
        address _paymentToken,
        uint256 _issuedTokenAmount,
        uint256 _price,
        uint256 _maxAllocPerUser,
        uint256 _depositStartTime,
        uint256 _depositDuration,
        uint256 _launchTime,
        uint256 _decimals
    ) external onlyOwner returns(address) {
        require(_issuer != address(0), "PadFactory: issuer can't be 0 address");
        require(_issuedToken != address(0), "PadFactory: issued token can't be 0 address");
        require(_paymentToken != address(0), "PadFactory: payment token can't be 0 address");
        require(_issuedTokenAmount > 0, "PadFactory: issued token amount need to be greater than 0");
        require(getModel[_issuedToken] == address(0), "PadFactory: token has already been issued");

        address primaryModelEvent = Clones.clone(primaryImplementation);

        getModel[_issuedToken] = primaryModelEvent;
        isModel[primaryModelEvent] = true;
        allPrimaryModels.push(primaryModelEvent);

        IPrimary(primaryModelEvent).initialize(
            _issuer, 
            _issuedToken, 
            _paymentToken, 
            _issuedTokenAmount, 
            _price, 
            _maxAllocPerUser, 
            _depositStartTime, 
            _depositDuration, 
            _launchTime, 
            _decimals
        );

        emit NewPrimaryModelEventCreated(
            primaryModelEvent, 
            _issuedToken, 
            _paymentToken,
            _depositStartTime,
            _depositDuration,
            _launchTime
        );

        return primaryModelEvent;
    }

    /// @notice Creates an unlimited model contract
    /// @param _issuer Address of the project issuing tokens for auction
    /// @param _issuedToken Token that will be issued through this launch event
    /// @param _paymentToken Token that will be raised through this launch event
    /// @param _issuedTokenAmount Amount of tokens that will be issued
    /// @param _price Price of each token in USD, scaled to 1e18
    /// @param _depositStartTime Timestamp of when launch event will start to deposit
    /// @param _depositDuration Timestamp of how long deposit phase will last for
    /// @param _launchTime Timestamp of when launch event will launch token
    /// @param _decimals Decimals of issuedToken
    /// @return Address of primary model launch event contract
    function createNewUnlimitedModel(
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
    ) external onlyOwner returns(address) {
        require(_issuer != address(0), "PadFactory: issuer can't be 0 address");
        require(_issuedToken != address(0), "PadFactory: issued token can't be 0 address");
        require(_paymentToken != address(0), "PadFactory: payment token can't be 0 address");
        require(_issuedTokenAmount > 0, "PadFactory: issued token amount need to be greater than 0");
        require(getModel[_issuedToken] == address(0), "PadFactory: token has already been issued");

        address unlimitedModelEvent = Clones.clone(unlimitedImplementation);

        getModel[_issuedToken] = unlimitedModelEvent;
        isModel[unlimitedModelEvent] = true;
        allUnlimitedModels.push(unlimitedModelEvent);

        IUnlimited(unlimitedModelEvent).initialize(
            _issuer, 
            _issuedToken, 
            _paymentToken, 
            _issuedTokenAmount, 
            _price, 
            _depositStartTime, 
            _depositDuration, 
            _launchTime, 
            _decimals,
            _minDeposit
        );

        emit NewUnlimitedModelEventCreated(
            unlimitedModelEvent, 
            _issuedToken, 
            _paymentToken,
            _depositStartTime,
            _depositDuration,
            _launchTime
        );

        return unlimitedModelEvent;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    struct Multiplier {
        uint256 multiplier10;
        uint256 multiplier15;
        uint256 multiplier20;
        uint256 multiplier25;
        uint256 multiplier50;
        uint256 multiplier100;
    }

    /// @notice multiplier list(scaled to 10)
    Multiplier public multiplier;

    /// @notice Set default fee rate
    ///> 0x & <= 1x => 1%(100/10000)
    ///> 1x & <= 1.5x => 0.5%(50/10000)
    ///> 1.5x & <= 2x => 0.3%(30/10000)
    ///> 2x & <= 2.5x => 0.25%(25/10000)
    ///> 2.5x & <= 5x => 0.2%(20/10000)
    ///> 5x & <= 10x => 0.1%(10/10000)
    ///> 10x => 0.05%(5/10000)
    function _setDefaultFeeRate() internal {
        _setMultiplierFeeRate(0, 100);
        _setMultiplierFeeRate(10, 50);
        _setMultiplierFeeRate(15, 30);
        _setMultiplierFeeRate(20, 25);
        _setMultiplierFeeRate(25, 20);
        _setMultiplierFeeRate(50, 10);
        _setMultiplierFeeRate(100, 5);
        multiplier = Multiplier(10, 15, 20, 25, 50, 100);
    }

    function _setMultiplierFeeRate(uint256 _multiplier, uint256 _feeRate) internal {
        multiplierFeeRate[_multiplier] = _feeRate;
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /// @notice Set address to collect participation fees of unlimited model
    /// @param _feeCollector New fee collector address
    function setFeeCollector(address _feeCollector)
        external
        onlyOwner
    {
        require(
            _feeCollector != address(0),
            "PadFactory: fee collector can't be address zero"
        );
        feeCollector = _feeCollector;
        emit SetFeeCollector(_feeCollector);
    }

    /// @notice Set amount of wNETT required to deposit x stablecoins into launch event
    /// @dev Configured by team between launch events to control inflation
    function setUSDPerWNETT(uint256 _USDPerWNETT) external onlyOwner {
        USDPerWNETT = _USDPerWNETT;
        emit SetUSDPerWNETT(_USDPerWNETT);
    }
    
    function addModel(address _model) 
        public 
        onlyOwner {
        isModel[_model] = true;
    }
    
    function delModel(address _model) 
        public 
        onlyOwner {
        isModel[_model] = false;
    }

    /// @notice Set multiplier fee rate for unlimited model
    /// @param _multiplier which multiplier to set
    /// @param _feeRate value of rate
    function setMultiplierFeeRate(uint256 _multiplier, uint256 _feeRate) 
        external 
        onlyOwner {
        _setMultiplierFeeRate(_multiplier, _feeRate);
        emit MulitplierFeeRateSet(msg.sender, _multiplier, _feeRate);
    }

    /// @notice Set the proxy implementation address
    /// @param _primaryImplementation The address of the primary implementation contract
    function setPrimaryImplementation(address _primaryImplementation)
        external
        onlyOwner
    {
        require(_primaryImplementation != address(0), "RJFactory: can't be null");
        primaryImplementation = _primaryImplementation;
        emit SetPrimaryImplementation(_primaryImplementation);
    }

    /// @notice Set the proxy implementation address
    /// @param _unlimitedImplementation The address of the primary implementation contract
    function setUnlimitedImplementation(address _unlimitedImplementation)
        external
        onlyOwner
    {
        require(_unlimitedImplementation != address(0), "RJFactory: can't be null");
        unlimitedImplementation = _unlimitedImplementation;
        emit SetUnlimitedImplementation(_unlimitedImplementation);
    }

    /* ========== EVENTS ========== */
    event MulitplierFeeRateSet(address indexed setter, uint256 multiplier, uint256 feeRate);
    event SetPrimaryImplementation(address indexed _primaryImplementation);
    event SetUnlimitedImplementation(address indexed _unlimitedImplementation);
    event SetFeeCollector(address indexed _feeCollector);
    event SetUSDPerWNETT(uint256 _USDPerWNETT);
    event NewPrimaryModelEventCreated(
        address indexed primaryModelEvent, 
        address indexed _issuedToken, 
        address indexed _paymentToken,
        uint256 _depositStartTime,
        uint256 _depositDuration,
        uint256 _launchTime
    );
    event NewUnlimitedModelEventCreated(
        address indexed unlimitedModelEvent, 
        address indexed _issuedToken, 
        address indexed _paymentToken,
        uint256 _depositStartTime,
        uint256 _depositDuration,
        uint256 _launchTime
    );
}