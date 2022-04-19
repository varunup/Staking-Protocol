// The following code is from flattening this file: contracts/StakingProtocol.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

// The following code is from flattening this import statement in: contracts/StakingProtocol.sol
// import "@openzeppelin/contracts/access/Ownable.sol";
// The following code is from flattening this file: /home/dev-varun/Documents/Solidity/Staking-Protocol/node_modules/@openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

// pragma solidity ^0.8.0;

// The following code is from flattening this import statement in: /home/dev-varun/Documents/Solidity/Staking-Protocol/node_modules/@openzeppelin/contracts/access/Ownable.sol
// import "../utils/Context.sol";
// The following code is from flattening this file: /home/dev-varun/Documents/Solidity/Staking-Protocol/node_modules/@openzeppelin/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// The following code is from flattening this import statement in: contracts/StakingProtocol.sol
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// The following code is from flattening this file: /home/dev-varun/Documents/Solidity/Staking-Protocol/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// The following code is from flattening this import statement in: contracts/StakingProtocol.sol
// import "./IStakingProtocol.sol";
// The following code is from flattening this file: /home/dev-varun/Documents/Solidity/Staking-Protocol/contracts/IStakingProtocol.sol

// pragma solidity ^0.8.12;


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



contract StakingProtocol is IStakingProtocol, Ownable {

    uint256 public poolCount;
    uint256 public cliff;
    bool public paused;

    mapping(uint256 => PoolInfo) public pool;
    mapping(address => mapping(uint256 => StakingInfo)) public stake;
    mapping(uint256 => bool) public poolStatus;

    function setCliff(uint256 _cliff) external virtual override onlyOwner returns (bool){
        cliff = _cliff;
        return true;
    }

    function changeStakingStatus(bool stakingStatus_) external virtual override onlyOwner returns (bool) {
        paused = stakingStatus_;
        return true;
    }

    function changePoolStatus(uint256 poolId, bool poolStatus_) external virtual override onlyOwner returns (bool) {
        require(poolId <= poolCount, "Inavlid Pool ID.");
        poolStatus[poolId] = poolStatus_;
        emit PoolStatusChanged(poolId, poolStatus_);
        return true;
    }

    function createPool( address stakingToken, address rewardToken, uint256 yieldPerSecond ) external virtual override onlyOwner returns (bool) {
        require(stakingToken != address(0) && rewardToken != address(0), "Invalid Stake Or Reward Token Address");
        poolCount += 1;
        pool[poolCount] = PoolInfo(stakingToken, rewardToken, yieldPerSecond, 0);
        emit PoolCreated(poolCount, stakingToken, rewardToken, yieldPerSecond);
        return true;
    }

    function stakeToken(uint256 poolId, uint256 amount) external virtual override returns (bool) {
        require(!paused, "Staking Is Paused.");
        require(poolId <= poolCount, "Invalid Pool ID.");
        require(poolStatus[poolId], "Pool Is Not Active");

        PoolInfo storage _poolInfo = pool[poolId];
        StakingInfo storage _stakeInfo = stake[_msgSender()][poolId];
        address tokenAddress = _poolInfo.stakingToken;

        require(IERC20(tokenAddress).allowance(_msgSender(), address(this)) >= amount, "Not Have Enough Allowance");
        require(IERC20(tokenAddress).balanceOf(_msgSender()) >= amount, "Sender Does Not Have Enough Balance");

        if (_stakeInfo.stakeAmount > 0) {
            uint256 unclaimedReward = fetchUnclaimedReward(poolId);

            assert(IERC20(_poolInfo.rewardToken).transfer(_msgSender(), unclaimedReward));
        }

        _stakeInfo.stakeAmount += amount;
        _stakeInfo.stakeTime = block.timestamp;
        _poolInfo.totalStaked += amount;

        assert(IERC20(_poolInfo.stakingToken).transferFrom(_msgSender(), address(this), amount));

        emit Staked(_msgSender(), amount, poolId, block.timestamp);

        return true;
    }

    function claimToken(uint256 poolId, bool unStaking) external virtual override returns (bool) {
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

            assert(IERC20(_poolInfo.stakingToken).transfer(_msgSender(), amount));
        }
        assert(IERC20(_poolInfo.rewardToken).transfer(_msgSender(), unclaimedReward));

        emit Claimed(_msgSender(), unclaimedReward, poolId, block.timestamp, unStaking);

        return true;
    }

    function stakeInfo(address user, uint256 poolId) external view virtual override returns (StakingInfo memory) {
        StakingInfo storage _stakeInfo = stake[user][poolId];

        if (block.timestamp > _stakeInfo.stakeTime + cliff) {
            return stake[user][poolId];
        } else {
            return stake[address(0)][0];
        }
    }

    function fetchUnclaimedReward(uint256 poolId) public view virtual override returns (uint256) {
        StakingInfo storage _stakeInfo = stake[_msgSender()][poolId];
        PoolInfo storage _poolInfo = pool[poolId];

        require(_stakeInfo.stakeAmount > 0, "Stake Amount Is Zero");

        uint256 totalStakeTime = block.timestamp - _stakeInfo.stakeTime;
        uint256 totalReward = _stakeInfo.stakeAmount * totalStakeTime * _poolInfo.yieldPerSecond;
        totalReward = (totalReward / 31536000);

        return totalReward;
    }

    /// @dev see {IMtkzStaking-fetchPool}
    function fetchPoolInfo(uint256 poolId) external view virtual override returns (PoolInfo memory)
    {
        return pool[poolId];
    }
}




