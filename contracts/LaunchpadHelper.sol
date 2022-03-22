// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./interfaces/IUnlimited.sol";
import "./interfaces/IPrimary.sol";
import "./interfaces/IPadFactory.sol";

/// @title Helper for launchpad v2
/// @author Netswap
/// @notice Helper contract to fetch launchpad v2 data
contract LaunchpadHelper {
    struct UnlimitedData {
        address issuedToken;
        address paymentToken;
        address id;
        uint256 depositStart;
        uint256 DEPOSIT_DURATION;
        uint256 launchTime;
        uint256 price;
        uint256 USDPerWNETT;
        uint256 issuedTokenAmount;
        uint256 targetRaised;
        uint256 issuedTokenDecimals;
        uint256 paymentTokenReserve;
        uint256 userCount;
        uint256 minDeposit;
        IUnlimited.UserInfo userInfo;
    }

    IPadFactory public padFactory;
    address public owner;

    /// @notice Create a new instance with required parameters
    /// @param _padFactory Address of the PadFactory
    constructor(address _padFactory) {
        padFactory = IPadFactory(_padFactory);
        owner = msg.sender;
    }

    /// @notice Get all unlimited launch event data
    /// @param _offset Index to start at when looking up launch events
    /// @param _limit Maximum number of launch event data to return
    /// @return Array of all unlimited launch event data
    function getAllUnlimitedEvents(uint256 _offset, uint256 _limit)
        external
        view
        returns (UnlimitedData[] memory)
    {
        UnlimitedData[] memory unlimitedData;
        (,,uint256 unlimitedNum) = padFactory.numModels();

        if (_offset >= unlimitedNum || _limit == 0) {
            return unlimitedData;
        }

        uint256 end = _offset + _limit > unlimitedNum
            ? unlimitedNum
            : _offset + _limit;
        unlimitedData = new UnlimitedData[](end - _offset);

        for (uint256 i = _offset; i < end; i++) {
            address unlimitedAddr = padFactory.allUnlimitedModels(i);
            IUnlimited unlimited = IUnlimited(unlimitedAddr);
            unlimitedData[i] = getUnlimitedEventData(unlimited);
        }
        return unlimitedData;
    }

    /// @notice Get all unlimited launch event datas with a given `_user`
    /// @param _offset Index to start at when looking up unlimited launch events
    /// @param _limit Maximum number of unlimited launch event datas to return
    /// @param _user User to lookup
    /// @return Array of all unlimited launch event datas with user info
    function getAllUnlimitedEventsWithUser(
        uint256 _offset,
        uint256 _limit,
        address _user
    ) external view returns (UnlimitedData[] memory) {
        UnlimitedData[] memory unlimitedData;
        (,,uint256 unlimitedNum) = padFactory.numModels();

        if (_offset >= unlimitedNum || _limit == 0) {
            return unlimitedData;
        }

        uint256 end = _offset + _limit > unlimitedNum
            ? unlimitedNum
            : _offset + _limit;
        unlimitedData = new UnlimitedData[](end - _offset);

        for (uint256 i = _offset; i < end; i++) {
            address unlimitedEventAddr = padFactory.allUnlimitedModels(i);
            IUnlimited unlimited = IUnlimited(unlimitedEventAddr);
            unlimitedData[i] = getUserUnlimitedEventData(unlimited, _user);
        }

        return unlimitedData;
    }

    function getUserUnlimitedEventData(IUnlimited _unlimited, address _user) 
        public 
        view 
        returns (UnlimitedData memory)
    {
        UnlimitedData memory unlimitedEventData = getUnlimitedEventData(
            _unlimited
        );
        unlimitedEventData.userInfo = _unlimited.getUserInfo(_user);
        unlimitedEventData.userInfo.allocation = _unlimited.getUserAllocation(_user);
        unlimitedEventData.userInfo.refunds = _unlimited.getUserRefunds(_user);
        return unlimitedEventData;
    }

    function getUnlimitedEventData(IUnlimited _unlimited) 
        public 
        view 
        returns (UnlimitedData memory) {
            uint256 paymentTokenReserve = _unlimited.paymentTokenReserve();
            IERC20Metadata issuedToken = _unlimited.issuedToken();
            IERC20Metadata paymentToken = _unlimited.paymentToken();

            return UnlimitedData({
               issuedToken: address(issuedToken),
               paymentToken: address(paymentToken),
               id: address(_unlimited),
               depositStart: _unlimited.depositStart(),
               DEPOSIT_DURATION: _unlimited.DEPOSIT_DURATION(),
               launchTime: _unlimited.launchTime(),
               price: _unlimited.price(),
               USDPerWNETT: _unlimited.USDPerWNETT(),
               issuedTokenAmount: _unlimited.issuedTokenAmount(),
               targetRaised: _unlimited.targetRaised(),
               issuedTokenDecimals: _unlimited.issuedTokenDecimals(),
               paymentTokenReserve: paymentTokenReserve,
               userCount: _unlimited.userCount(),
               minDeposit: _unlimited.minDeposit(),
               userInfo: IUnlimited.UserInfo({
                    allocation: 0,
                    balance: 0,
                    refunds: 0,
                    hasClaimedRefunds: false
                })
            });
    }

    function setPadFactory(address _newFactory) external {
        require(msg.sender == owner, "not owner");
        padFactory = IPadFactory(_newFactory);
    }

}
