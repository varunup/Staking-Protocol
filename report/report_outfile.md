## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| contracts/StakingProtocol.sol | 0cf37e31896d5a8026bc0763d189d56b81f8f153 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **StakingProtocol** | Implementation | IStakingProtocol, Ownable |||
| └ | setCliff | External ❗️ | 🛑  | onlyOwner |
| └ | changeStakingStatus | External ❗️ | 🛑  | onlyOwner |
| └ | changePoolStatus | External ❗️ | 🛑  | onlyOwner |
| └ | createPool | External ❗️ | 🛑  | onlyOwner |
| └ | stakeToken | External ❗️ | 🛑  |NO❗️ |
| └ | claimToken | External ❗️ | 🛑  |NO❗️ |
| └ | stakeInfo | External ❗️ |   |NO❗️ |
| └ | fetchUnclaimedReward | Public ❗️ |   |NO❗️ |
| └ | fetchPoolInfo | External ❗️ |   |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
