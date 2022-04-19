// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IStakingProtocol.sol";

contract StakingProtocol is IStakingProtocol, Ownable {
    uint256 public poolCount;
    uint256 public cliff;
    bool public paused;

    mapping(uint256 => PoolInfo) public pool;
    mapping(address => mapping(uint256 => StakingInfo)) public stake;
    mapping(uint256 => bool) public poolStatus;

    function setCliff(uint256 _cliff)
        external
        virtual
        override
        onlyOwner
        returns (bool)
    {
        cliff = _cliff;
        return true;
    }

    function changeStakingStatus(bool stakingStatus_)
        external
        virtual
        override
        onlyOwner
        returns (bool)
    {
        paused = stakingStatus_;
        return true;
    }

    function changePoolStatus(uint256 poolId, bool poolStatus_)
        external
        virtual
        override
        onlyOwner
        returns (bool)
    {
        require(poolId <= poolCount, "Inavlid Pool ID.");
        poolStatus[poolId] = poolStatus_;
        emit PoolStatusChanged(poolId, poolStatus_);
        return true;
    }

    function createPool(
        address stakingToken,
        address rewardToken,
        uint256 yieldPerSecond
    ) external virtual override onlyOwner returns (bool) {
        require(
            stakingToken != address(0) && rewardToken != address(0),
            "Invalid Stake Or Reward Token Address"
        );
        poolCount += 1;
        pool[poolCount] = PoolInfo(
            stakingToken,
            rewardToken,
            yieldPerSecond,
            0
        );
        emit PoolCreated(poolCount, stakingToken, rewardToken, yieldPerSecond);
        return true;
    }

    function stakeToken(uint256 poolId, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        require(!paused, "Staking Is Paused.");
        require(poolId <= poolCount, "Invalid Pool ID.");
        require(poolStatus[poolId], "Pool Is Not Active");

        PoolInfo storage _poolInfo = pool[poolId];
        StakingInfo storage _stakeInfo = stake[_msgSender()][poolId];
        address tokenAddress = _poolInfo.stakingToken;

        require(
            IERC20(tokenAddress).allowance(_msgSender(), address(this)) >=
                amount,
            "Not Have Enough Allowance"
        );
        require(
            IERC20(tokenAddress).balanceOf(_msgSender()) >= amount,
            "Sender Does Not Have Enough Balance"
        );

        if (_stakeInfo.stakeAmount > 0) {
            uint256 unclaimedReward = fetchUnclaimedReward(poolId);

            assert(
                IERC20(_poolInfo.rewardToken).transfer(
                    _msgSender(),
                    unclaimedReward
                )
            );
        }

        _stakeInfo.stakeAmount += amount;
        _stakeInfo.stakeTime = block.timestamp;
        _poolInfo.totalStaked += amount;

        assert(
            IERC20(_poolInfo.stakingToken).transferFrom(
                _msgSender(),
                address(this),
                amount
            )
        );

        emit Staked(_msgSender(), amount, poolId, block.timestamp);

        return true;
    }

    function claimToken(uint256 poolId, bool unStaking)
        external
        virtual
        override
        returns (bool)
    {
        require(!paused, "Staking Is Paused");
        uint256 unclaimedReward = fetchUnclaimedReward(poolId);
        require(unclaimedReward > 0, "No Reward To Claim");

        PoolInfo storage _poolInfo = pool[poolId];
        StakingInfo storage _stakeInfo = stake[_msgSender()][poolId];

        uint256 amount = _stakeInfo.stakeAmount;
        _stakeInfo.stakeTime = block.timestamp;

        if (unStaking) {
            _stakeInfo.stakeAmount = 0;
            _poolInfo.totalStaked -= _stakeInfo.stakeAmount;

            assert(
                IERC20(_poolInfo.stakingToken).transfer(_msgSender(), amount)
            );
        }
        assert(
            IERC20(_poolInfo.rewardToken).transfer(
                _msgSender(),
                unclaimedReward
            )
        );

        emit Claimed(
            _msgSender(),
            unclaimedReward,
            poolId,
            block.timestamp,
            unStaking
        );

        return true;
    }

    function stakeInfo(address user, uint256 poolId)
        external
        view
        virtual
        override
        returns (StakingInfo memory)
    {
        StakingInfo storage _stakeInfo = stake[user][poolId];

        if (block.timestamp > _stakeInfo.stakeTime + cliff) {
            return stake[user][poolId];
        } else {
            return stake[address(0)][0];
        }
    }

    function fetchUnclaimedReward(uint256 poolId)
        public
        view
        virtual
        override
        returns (uint256)
    {
        StakingInfo storage _stakeInfo = stake[_msgSender()][poolId];
        PoolInfo storage _poolInfo = pool[poolId];

        require(_stakeInfo.stakeAmount > 0, "Stake Amount Is Zero");

        uint256 totalStakeTime = block.timestamp - _stakeInfo.stakeTime;
        uint256 totalReward = _stakeInfo.stakeAmount *
            totalStakeTime *
            _poolInfo.yieldPerSecond;
        totalReward = (totalReward / 31536000);

        return totalReward;
    }

    /// @dev see {IMtkzStaking-fetchPool}
    function fetchPoolInfo(uint256 poolId)
        external
        view
        virtual
        override
        returns (PoolInfo memory)
    {
        return pool[poolId];
    }
}
