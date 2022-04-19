// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;


interface IStakingProtocol {

    struct PoolInfo {
        address stakingToken;
        address rewardToken;
        uint256 yieldPerSecond;
        uint256 totalStaked;
    }

    struct StakingInfo {
        uint256 stakeTime;
        uint256 stakeAmount;
    }

    event PoolCreated( uint256 poolId, address stakingToken, address rewardToken, uint256 yieldPerSecond );
    event PoolStatusChanged(uint256 poolId, bool poolStatus);
    event Staked(address user, uint256 amount, uint256 poolId, uint256 time);
    event Claimed( address user, uint256 reward, uint256 poolId, uint256 time, bool unStaking);

    function setCliff(uint256 _cliff) external returns (bool);

    function createPool( address stakingToken, address rewardToken, uint256 yieldPerSecond ) external returns (bool);

    function changePoolStatus(uint256 poolId, bool poolStatus_) external returns (bool);

    function changeStakingStatus(bool stakingStatus) external returns (bool);

    function stakeToken(uint256 poolId, uint256 amount) external returns (bool);

    function claimToken(uint256 poolId, bool unStaking) external returns (bool);

    function stakeInfo(address user, uint256 poolId) external returns (StakingInfo memory);

    function fetchUnclaimedReward(uint256 poolId) external returns (uint256);

    function fetchPoolInfo(uint256 poolId) external returns (PoolInfo memory);
}
