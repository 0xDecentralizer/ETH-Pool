//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

// MohammadMahdiKeshavarz1382@gmail.com

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
