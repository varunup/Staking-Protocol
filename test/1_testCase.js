/** @format */

const { BN, time } = require('@openzeppelin/test-helpers');
const { ZERO_ADDRESS } = require('@openzeppelin/test-helpers/src/constants');

const Staking = artifacts.require('StakingProtocol');
const Token = artifacts.require('Token');

contract('Staking Protocol', (accounts) => {
  let instance;
  let stakingToken;
  const owner = accounts[1];
  const user = accounts[2];

  beforeEach(async () => {
    instance = await Staking.new({ from: owner });
    stakingToken = await Token.new({ from: owner });
    rewardToken = await Token.new({ from: owner });

    await stakingToken.transfer(user, new BN(10).pow(new BN(23)), { from: owner });
    await stakingToken.approve(instance.address, new BN(10).pow(new BN(18)), { from: user });
    await rewardToken.transfer(instance.address, 10 ** 10, { from: owner });
  });

  it('Should be able to check public variable in staking protocol', async () => {
    await instance.setCliff(10, { from: owner });
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    await instance.changePoolStatus(1, true, { from: owner });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    let now = await time.latest();
    await time.increaseTo(now.add(time.duration.minutes(10)));

    const poolCount_ = await instance.poolCount();
    const cliff_ = await instance.cliff();
    const paused_ = await instance.paused.call();
    const poolInfo_ = await instance.fetchPoolInfo(1);
    const stakeInfo_ = await instance.stakeInfo(user, 1);
    const poolStatus_ = await instance.poolStatus.call(1);

    assert.equal(poolCount_.toNumber(), 1, 'Wrong Value');
    assert.equal(cliff_.toNumber(), 10, 'Wrong Value');
    assert.equal(paused_, false, 'Wrong Value');
    assert.equal(poolInfo_['yieldPerSecond'], 100, 'Wrong Value');
    assert.equal(stakeInfo_['stakeAmount'], 10 ** 10, 'Wrong Value');
    assert.equal(poolStatus_, true, 'Wrong Value');
  });

  it('Should be able to set cliff value in staking protocol', async () => {
    await instance.setCliff(1000, { from: owner });
    const cliff_ = await instance.cliff();

    assert.equal(cliff_.toNumber(), 1000, 'Wrong Value');
  });

  it('Should not be able to set cliff if not called by owner', async () => {
    try {
      await instance.setCliff(1000);
      const cliff_ = await instance.cliff();

      assert.equal(cliff_.toNumber(), 1000, 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Ownable: caller is not the owner -- Reason given: Ownable: caller is not the owner.';
      assert.equal(error.message, var_, 'Unable to set cliff');
    }
  });

  it('Should be able to change staking status on staking protocol', async () => {
    await instance.changeStakingStatus(true, { from: owner });
    const paused_ = await instance.paused.call();

    assert.equal(paused_, true, 'Wrong Value');
  });

  it('Should not be able to change staking status when not called by owner', async () => {
    try {
      await instance.changeStakingStatus(true);
      const paused_ = await instance.paused.call();

      assert.equal(paused_, true, 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Ownable: caller is not the owner -- Reason given: Ownable: caller is not the owner.';
      assert.equal(error.message, var_, 'Unable to change status of staking');
    }
  });

  it('Should be able to change pool status on staking protocol', async () => {
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    await instance.changePoolStatus(1, true, { from: owner });
    const poolStatus_ = await instance.poolStatus(1);

    assert.equal(poolStatus_, true, 'Wrong Value');
  });

  it('Should not be able to change pool status when not called by owner', async () => {
    try {
      await instance.changePoolStatus(1, true);
      const poolStatus_ = await instance.poolStatus.call(1);

      assert.equal(poolStatus_, true, 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Ownable: caller is not the owner -- Reason given: Ownable: caller is not the owner.';
      assert.equal(error.message, var_, 'Unable to change status of pool');
    }
  });

  it('Should not be able to change pool status when poolId is not valid', async () => {
    try {
      await instance.changePoolStatus(2, true, { from: owner });
      const poolStatus_ = await instance.poolStatus.call(1);

      assert.equal(poolStatus_, true, 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Inavlid Pool ID. -- Reason given: Inavlid Pool ID..';
      assert.equal(error.message, var_, 'Unable to change status of pool');
    }
  });

  it('Should be able to create new pool on staking protocol', async () => {
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    const poolId = await instance.poolCount();

    assert.equal(poolId, 1, 'Wrong Value');
  });

  it('Should not be able to create new pool when not called by owner', async () => {
    try {
      await instance.createPool(stakingToken.address, rewardToken.address, 100);
      const poolId = await instance.poolCount();

      assert.equal(poolId, 1, 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Ownable: caller is not the owner -- Reason given: Ownable: caller is not the owner.';
      assert.equal(error.message, var_, 'Unable to create new pool');
    }
  });
  it('Should not be able to create new pool when stakingToken address is zero', async () => {
    try {
      await instance.createPool(ZERO_ADDRESS, rewardToken.address, 100, { from: owner });
      const poolId = await instance.poolCount();

      assert.equal(poolId, 1, 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Invalid Stake Or Reward Token Address -- Reason given: Invalid Stake Or Reward Token Address.';
      assert.equal(error.message, var_, 'Unable to create new pool');
    }
  });
  it('Should not be able to create new pool when rewardToken address is zero', async () => {
    try {
      await instance.createPool(stakingToken.address, ZERO_ADDRESS, 100, { from: owner });
      const poolId = await instance.poolCount();

      assert.equal(poolId, 1, 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Invalid Stake Or Reward Token Address -- Reason given: Invalid Stake Or Reward Token Address.';
      assert.equal(error.message, var_, 'Unable to create new pool');
    }
  });

  it('Should be able to stake token on staking protocol', async () => {
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    await instance.changePoolStatus(1, true, { from: owner });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    let now = await time.latest();
    await time.increaseTo(now.add(time.duration.minutes(10)));
    const result = await instance.stakeInfo(user, 1);

    assert.equal(result['stakeAmount'], 10 ** 10, 'Wrong Value');
  });

  it('Should be able to stake token on staking protocol, when staking second time', async () => {
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    await instance.changePoolStatus(1, true, { from: owner });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    let now = await time.latest();
    await time.increaseTo(now.add(time.duration.minutes(10)));
    const result = await instance.stakeInfo(user, 1);

    assert.equal(result['stakeAmount'], 2 * 10 ** 10, 'Wrong Value');
  });

  it('Should not be able to stake token when staking is paused', async () => {
    try {
      await instance.changeStakingStatus(true, { from: owner });
      await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
      await instance.changePoolStatus(1, true, { from: owner });
      await instance.stakeToken(1, 10 ** 10, { from: user });
      const result = await instance.stakeInfo(user, 1);

      assert.equal(result['stakeAmount'], new BN(10 ** 10), 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Staking Is Paused. -- Reason given: Staking Is Paused..';
      assert.equal(error.message, var_, 'Unable to stake token');
    }
  });

  it('Should not be able to stake token when poolId is not valid', async () => {
    try {
      await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
      await instance.changePoolStatus(1, true, { from: owner });
      await instance.stakeToken(5, 10 ** 10, { from: user });
      const result = await instance.stakeInfo(user, 1);

      assert.equal(result['stakeAmount'], new BN(10 ** 10), 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Invalid Pool ID. -- Reason given: Invalid Pool ID..';
      assert.equal(error.message, var_, 'Unable to stake token');
    }
  });

  it('Should not be able to stake token when poolStatus is false', async () => {
    try {
      await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
      await instance.changePoolStatus(1, false, { from: owner });
      await instance.stakeToken(1, 10 ** 10, { from: user });
      const result = await instance.stakeInfo(user, 1);

      assert.equal(result['stakeAmount'], new BN(10 ** 10), 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Pool Is Not Active -- Reason given: Pool Is Not Active.';
      assert.equal(error.message, var_, 'Unable to stake token');
    }
  });

  it('Should not be able to stake token when staking address does not have allowance', async () => {
    try {
      stakingToken.approve(instance.address, 0, { from: user });
      await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
      await instance.changePoolStatus(1, true, { from: owner });
      await instance.stakeToken(1, 10 ** 10, { from: user });
      const result = await instance.stakeInfo(user, 1);

      assert.equal(result['stakeAmount'], new BN(10 ** 10), 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Not Have Enough Allowance -- Reason given: Not Have Enough Allowance.';
      assert.equal(error.message, var_, 'Unable to stake token');
    }
  });

  it('Should not be able to stake token when amount is more than balance', async () => {
    try {
      await stakingToken.approve(instance.address, new BN(10).pow(new BN(26)), { from: user });
      await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
      await instance.changePoolStatus(1, true, { from: owner });
      await instance.stakeToken(1, new BN(10).pow(new BN(25)), { from: user });
      const result = await instance.stakeInfo(user, 1);

      assert.equal(result['stakeAmount'].toNumber(), 10 ** 10, 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Sender Does Not Have Enough Balance -- Reason given: Sender Does Not Have Enough Balance.';
      assert.equal(error.message, var_, 'Unable to stake token');
    }
  });

  //   it('Should not be able to stake token when contract does not have enough reward token', async () => {
  //     try {

  //       await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
  //   await instance.changePoolStatus(1, true,{from:owner});
  //       await instance.stakeToken(1, 10 ** 10, { from: user });
  //       await instance.stakeToken(1, 10 ** 10, { from: user });
  //       const result = await instance.stakeInfo(user, 1);

  //       assert.equal(result['stakeAmount'], new BN(10 ** 10), 'Wrong Value');
  //     } catch (error) {
  //       let var_ = ' ';
  //       assert.equal(error.message, var_, 'Unable to stake token');
  //     }
  //   });

  //   it('Should not be able to stake token when', async () => {
  //     try {
  //       await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
  //   await instance.changePoolStatus(1, true,{from:owner});
  //       await instance.stakeToken(1, 10 ** 10, { from: user });
  //       const result = await instance.stakeInfo(user, 1);

  //       assert.equal(result['stakeAmount'], new BN(10 ** 10), 'Wrong Value');
  //     } catch (error) {
  //       let var_ = ' ';
  //       assert.equal(error.message, var_, 'Unable to stake token');
  //     }
  //   });

  it('Should be able to claim reward from staking contract', async () => {
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    await instance.changePoolStatus(1, true, { from: owner });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    let now = await time.latest();
    await time.increaseTo(now.add(time.duration.minutes(10)));
    await instance.claimToken(1, false, { from: user });
    const result = await instance.fetchUnclaimedReward(1, { from: user });

    assert.equal(result, 0, 'Wrong Value');
  });

  it('Should be able to claim reward from staking contract and unStakingToken', async () => {
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    await instance.changePoolStatus(1, true, { from: owner });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    let now = await time.latest();
    await time.increaseTo(now.add(time.duration.minutes(10)));
    await instance.claimToken(1, true, { from: user });
    const result = await instance.stakeInfo(user, 1);

    assert.equal(result['stakeAmount'], new BN(0), 'Wrong Value');
  });

  it('Should not be able to claim or unStakingToken from staking protocol when staking is paused', async () => {
    try {
      await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
      await instance.changePoolStatus(1, true, { from: owner });
      await instance.stakeToken(1, 10 ** 10, { from: user });
      await instance.changeStakingStatus(true, { from: owner });
      let now = await time.latest();
      await time.increaseTo(now.add(time.duration.minutes(10)));
      await instance.claimToken(1, true, { from: user });
      const result = await instance.stakeInfo(user, 1);

      assert.equal(result['stakeAmount'], new BN(0), 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Staking Is Paused -- Reason given: Staking Is Paused.';
      assert.equal(error.message, var_, 'Unable to claim token or unStake from contract');
    }
  });

  it('Should not be able to claim or unStakingToken from staking protocol when unclaimedReward is zero', async () => {
    try {
      await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
      await instance.changePoolStatus(1, true, { from: owner });
      await instance.stakeToken(1, 10 ** 10, { from: user });
      await instance.claimToken(1, false, { from: user });
      await instance.claimToken(1, false, { from: user });
      const result = await instance.stakeInfo(user, 1);

      assert.equal(result['stakeAmount'], new BN(0), 'Wrong Value');
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert No Reward To Claim -- Reason given: No Reward To Claim.';
      assert.equal(error.message, var_, 'Unable to claim token or unStake from contract');
    }
  });

  //   it('Should not be able to claim or unstakingToken from staking protocol', async () => {
  //     try {
  //       await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
  //   await instance.changePoolStatus(1, true,{from:owner});
  //       await instance.stakeToken(1, 10 ** 10, { from: user });
  //       let now = await time.latest();
  //       await time.increaseTo(now.add(time.duration.minutes(10)));
  //       await instance.claimToken(1, false);
  //       const result = await instance.stakeInfo(user, 1);

  //       assert.equal(result['stakeAmount'], new BN(0), 'Wrong Value');
  //     } catch (error) {
  //       let var_ = '';
  //       assert.equal(error.message, var_, 'Unable to claim token or unStake from contract');
  //     }
  //   });

  //   it('Should not be able to claim or unstakingToken from staking protocol', async () => {
  //     try {
  //       await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
  //   await instance.changePoolStatus(1, true,{from:owner});
  //       await instance.stakeToken(1, 10 ** 10, { from: user });
  //       let now = await time.latest();
  //       await time.increaseTo(now.add(time.duration.minutes(10)));
  //       await instance.claimToken(1, false);
  //       const result = await instance.stakeInfo(user, 1);

  //       assert.equal(result['stakeAmount'], new BN(0), 'Wrong Value');
  //     } catch (error) {
  //       let var_ = '';
  //       assert.equal(error.message, var_, 'Unable to claim token or unStake from contract');
  //     }
  //   });

  it('Should be able to get stakeInfo from staking contract', async () => {
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    await instance.changePoolStatus(1, true, { from: owner });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    let now = await time.latest();
    await time.increaseTo(now.add(time.duration.minutes(10)));
    const result = await instance.stakeInfo(user, 1);

    assert.equal(result['stakeAmount'], 10 ** 10, 'Wrong Value');
  });

  it('Should be able to call stakeInfo func when cliff time is not passed', async () => {
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    await instance.changePoolStatus(1, true, { from: owner });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    let now = await time.latest();
    await time.increaseTo(now.add(time.duration.minutes(10)));
    const result = await instance.stakeInfo(user, 1);

    assert.equal(result['stakeAmount'], 10 ** 10, 'Wrong Value');
  });

  it('Should be able to get fetchUnclaimedReward from staking contract', async () => {
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    await instance.changePoolStatus(1, true, { from: owner });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    let now = await time.latest();
    await time.increaseTo(now.add(time.duration.minutes(10)));
    const result = await instance.fetchUnclaimedReward(1, { from: user });

    assert(result);
  });

  it('Should not be able to fetchUnclaimedReward when stakeAmount is zero', async () => {
    try {
      await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
      await instance.changePoolStatus(1, true, { from: owner });
      await instance.stakeToken(1, 10 ** 10, { from: user });
      let now = await time.latest();
      await time.increaseTo(now.add(time.duration.minutes(10)));
      await instance.claimToken(1, true, { from: user });
      await instance.fetchUnclaimedReward(1, { from: user });
    } catch (error) {
      let var_ = 'Returned error: VM Exception while processing transaction: revert Stake Amount Is Zero';
      assert.equal(error.message, var_, 'Unable to fetchUnclaimedReward');
    }
  });

  it('Should be able to get pool info from staking contract', async () => {
    await instance.createPool(stakingToken.address, rewardToken.address, 100, { from: owner });
    await instance.changePoolStatus(1, true, { from: owner });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    await instance.stakeToken(1, 10 ** 10, { from: user });
    let now = await time.latest();
    await time.increaseTo(now.add(time.duration.minutes(10)));
    const result = await instance.fetchPoolInfo(1);

    assert.equal(result['totalStaked'], 2 * 10 ** 10, 'Wrong Value');
  });
});
