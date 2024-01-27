// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    //before you join a lottery you have to stake somehing, it shold be an address coming in with a certain value, we need to capture all address
    //and we use an adrress in an array, and the addresses are payable, to receive ether once won.abi

    address payable [] public players;
    
    //we need to put someone in charge, the nigga to deploy the contract, kinda admin
    address public manager;

    constructor () {
        manager = msg.sender;
    }

    //players must deposit 0.01 minimum, so we make use of receicve method, so the contract can receive eth.. fallback/receive function
    receive() external payable{
        require (msg.value == 0.1 ether);

        players.push(payable(msg.sender)); //we need to capture the address of the person buying in, and we do that by pushing it into th array
        // and it's payable because without it, their funds would be lost...
    }

    //we need to get track of balances
    function getBalance () public view returns (uint) {
        require (msg.sender == manager);
        return address(this).balance;    //this refers to everything in our contract,  .balance- balance of the contract
    }

    //we need to randomize everything in the array, to avoid cheating, so we create a random function
    function random () internal view returns (uint) {
        return uint (keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner () public {
        require (msg.sender == manager);
        require(players.length >= 3);

        uint rand = random();

        address payable winner;

        uint index = rand % players.length;

        winner = players[index];

        // we wanna settle the  manager with some percentage say 10% of the winnings, hence the winner takes 90%
        uint managerFee = (getBalance()*10)/100;
        
        uint winnersPrice = (getBalance()*90)/100;

        //we transfer the money accordingly
        winner.transfer(winnersPrice);

        //we make the manager address payable as it wasn't payable from the scratch, see line 11
        payable(manager).transfer(managerFee);

        //now we restart the whole process, clean up  the array so, the next lottery batch will enter
        players = new address payable[](0);


    }

}