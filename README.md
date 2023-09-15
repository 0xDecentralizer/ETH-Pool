# ETHPool CHALLENGE:

ETHPool provides a service where people can deposit ETH and they will receive weekly rewards. Users must be able to take out their deposits along with their portion of rewards at any time. New rewards are deposited manually into the pool by the ETHPool team each week using a contract function.

#### _Requirements_:
1-Only the team can deposit rewards. 
2-Deposited rewards go to the pool of users, not to individual users.

**Example:** Let say we have user A and B and team T. A deposits 100, and B deposits 300 for a total of 400 in the pool. Now A has 25% of the pool and B has 75%. When T deposits 200 rewards, A should be able to withdraw 150 and B 450. What if the following happens? A deposits then T deposits then B deposits then A withdraws and finally B withdraws. A should get their deposit + all the rewards. B should only get their deposit because rewards were sent to the pool before they participated.

#### Goal:
1-Design and code a contract for ETHPool, take all the assumptions you need to move forward.
2-You can use any development tools you prefer: Hardhat, Truffle, Brownie, Solidity, Vyper.

//hello