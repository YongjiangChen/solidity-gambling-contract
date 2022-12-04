// SPDX-License-Identifier: GPL-3.0 

pragma solidity >=0.7.0 <0.9.0;


contract DiceGame {
    mapping(address => uint256) balance; 
    address[] public players; 
    address[] public customers;
    uint counter =1;
    uint constant private MIN_DEPOSITE = 3 ether; 
    
    event Deposit(address customer, string message, address[] customers); 
    event Withdrawal(address customer);
    event RandomNum(uint256 randomNum);
    event Message(string message);
    
    function deposit(string memory message) public payable { 
        require(msg.value > 0);
        balance[msg.sender] += msg.value; 

        customers.push(msg.sender);

        emit Deposit(msg.sender, message, customers); 
    }


    function readyForGame() public {
        require(balance[msg.sender] >= MIN_DEPOSITE, "Please make sure you have enough balance > 3 ETH");

        players.push(msg.sender);
        if (players.length >= 2){
            address playerA = players[0];
            address playerB = players[1];

            emit Message("enough players ready");

            startGame(playerA, playerB);
            
        } 
        else {
            emit Message("waiting for another player");
        }
        
    }

    function startGame(address playerA, address playerB) private {

        uint256 n = randomNumGenerator();
        emit RandomNum(n);

        address winner; address loser;
        
        if (n <= 3){
            winner = playerA;
            loser = playerB;
            emit Message("dice < 3");
        } 
        else{
            winner = playerB;
            loser = playerA;
            n -= 3;
            emit Message("dice > 3");
        }

        uint amount = ETHConvert(n);
        balance[winner] += amount;
        balance[loser] -= amount;

        players.pop();
        players.pop(); 
    }

    function ETHConvert(uint value) private pure returns(uint) {
        return value * 1e18;
    }

    function randomNumGenerator() private returns (uint256) {
        counter++;
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players,counter))) % 6 + 1;

    }

    function withdraw() public { 
        uint256 b = balance[msg.sender]; 
        balance[msg.sender] = 0; 
        payable(msg.sender).transfer(b); 

        emit Withdrawal(msg.sender);
    }

    function getBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

}
