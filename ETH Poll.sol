//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

// MohammadMahdiKeshavarz1382@gmail.com

// All of my comments was incorrect so i deside to write them again!
contract ETH_Pool {

    address owner;
    uint public poolBalance;
    uint public reward;
    uint countDeposit;
    uint countWithdraw;

    mapping(address => uint) userDeposit_COMPUTE;
    mapping(address => uint) public userDeposit;
    mapping(address => uint) public userEarned;
    mapping(address => uint) public lastRun;

    constructor() {
        owner = msg.sender;
    }
    
    function deposit() public payable {
        if(msg.sender == owner) {
            reward = msg.value;

        }
        else {
            userDeposit_COMPUTE[msg.sender] += msg.value;
            userDeposit[msg.sender] += msg.value;
            poolBalance += msg.value;
            countDeposit++; //Number of deposits
            lastRun[msg.sender] = block.timestamp;
        }
        require(msg.value > 0, "Can't deposit nothing!");
    }

    function ifTheAllRewardsAreWithdraw() private {
        if(countWithdraw == countDeposit)
            poolBalance = 0;
    }

    function withdraw() public {
        
        // require(block.timestamp - lastRun[msg.sender] > 1 minutes, "You cannot withdraw befor ");
        require(msg.sender != owner, "Owner can't withdra!"); //Ensuring that the owner cannot withdraw
        require(countDeposit >= countWithdraw, "All rewards are cleaned!"); //Preventing additional Trx after withdrawal of all users
        require(userDeposit_COMPUTE[msg.sender] > 0, "You withdraw befor!"); //Preventing withdraw again

        if(block.timestamp - lastRun[msg.sender] > 45 seconds) {
            // Calculate the percentage of users' rewards:
            uint temp1 = userDeposit_COMPUTE[msg.sender]; 
            uint temp2 = (((userDeposit_COMPUTE[msg.sender]*100) / poolBalance) * reward) / 100;

            // Transfer the users `reward + balance` to `msg.sender`: 
            payable(msg.sender).transfer(temp1 + temp2);

            userDeposit_COMPUTE[msg.sender] = 0; 
            userEarned[msg.sender] += temp2; //temp2 is the percentage of users' earned reward at this withdraw
            countWithdraw++; //Number of withdrawals

            // Check that if all users have withdrawan their own reward and deposits
            // the `poolBalance` will be equal zero for next `ETHPool events`!
            //
            // If `poolBalance` doesn't equal to 0, then in the second and more `ETHPool events` the `poolBalance` in
            // `temp2` will be a larger number than actual pool balance
            // and `temp2` will be a wrong and less number and users rewards will not pay completely.
            ifTheAllRewardsAreWithdraw();
        }
        else {
            uint temp1 = userDeposit_COMPUTE[msg.sender]; 
            uint temp2 = (((userDeposit_COMPUTE[msg.sender]*100) / poolBalance) * reward) / 100;
            temp2 = temp2 / 2; //Due to the withdrawal before the deadline(a week), The user will receive only half of the reward

            payable(msg.sender).transfer(temp1 + temp2);

            userDeposit_COMPUTE[msg.sender] = 0; 
            userEarned[msg.sender] += temp2;
            countWithdraw++;

            ifTheAllRewardsAreWithdraw();
        }

    }

    function cleanPool() public {
        require(msg.sender == owner, "Only owner can clean the pool!");
        require(poolBalance == 0 && address(this).balance > 0);

        payable(owner).transfer(address(this).balance);

    }
}

/*
    ETHPool CHALLENGE:
      ETHPool provides a service where people can deposit ETH and they will receive weekly rewards.
      Users must be able to take out their deposits along with their portion of rewards at any time.
      New rewards are deposited manually into the pool by the ETHPool team each week using a contract function.
    ---------------
    Requirements:
      -Only the team can deposit rewards.
      -Deposited rewards go to the pool of users, not to individual users.
      -Users should be able to withdraw their deposits along with their share of rewards considering the
       time when they deposited.
    ---------------
    Example:
      Let say we have user A and B and team T.
      A deposits 100, and B deposits 300 for a total of 400 in the pool. Now A has 25% of the pool and B has 75%.
      When T deposits 200 rewards, A should be able to withdraw 150 and B 450.
      What if the following happens? A deposits then T deposits then B deposits then A withdraws and finally B withdraws.
      A should get their deposit + all the rewards. B should only get their deposit because rewards were sent
      to the pool before they participated.
    ---------------
    Goal:
    -Design and code a contract for ETHPool, take all the assumptions you need to move forward.
    -You can use any development tools you prefer: Hardhat, Truffle, Brownie, Solidity, Vyper.
*/


// problems:
//   -Becuase of `poolBalance` that it wont be 0 after all withdrawals, in the 
//    second or more withdrawals it will divide the user's reward twoice and more.
// IT SOLVED !!!!!! YOOHOOO
