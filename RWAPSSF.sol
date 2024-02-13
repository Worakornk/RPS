// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./CommitReveal.sol";

/*
Here's the rules

Numbers represented in player[].choice
0 - Rock
1 - Fire
2 - Scissors
3 - Sponge
4 - Paper
5 - Air
6 - Water

*/

contract RPS is CommitReveal {

    struct Player {
        uint64 choice;
        bool isPlayed;
        address addr;
    }

    mapping (uint256 => Player) public player;
    uint256 public numPlayer = 0;
    uint256 public reward = 0;
    uint256 public numInput = 0;
    uint256 public numShowedChoices = 0;
    uint256 public ALLOWED_IDLE_TIME = 1 minutes;
    uint256 public lastActionTime = block.timestamp;
    
    function _resetGame() private {
        numPlayer = 0;
        reward = 0;
        numInput = 0;
        numShowedChoices = 0;
        delete player[0];
        delete player[1];
    }

    //Adding Player
    function addPlayer() public payable {
        require(numPlayer < 2, "Maximum number of players reached");
        require(msg.value == 1 ether, "Incorrect payment amount");
        reward += msg.value;
        player[numPlayer].addr = msg.sender;
        emit playerAdded(numPlayer, msg.sender); // Now we know we added more player
        player[numPlayer].choice = 7; // 7 is used to catch players that don't play the game
        player[numPlayer].isPlayed = false;
        numPlayer++;
        lastActionTime = block.timestamp;
    }

    event playerAdded(uint256 id, address addr);

    // Encrypt input with salt
    function getHashedChoiceWithSalt(uint64 choice, string memory salt)
        external
        pure
        returns (bytes32)
    {
        bytes32 encodedSalt = bytes32(abi.encodePacked(salt));
        return keccak256(abi.encodePacked(choice, encodedSalt));
    }

    // Takes uint64 choices and turn it into encoded salt
    function Input_HashedChoice(bytes32 hashed_salted_choice, uint256 idx) public  {
        require(numPlayer == 2, "Only playable if there are 2 players in total");
        require(msg.sender == player[idx].addr);
        require(player[idx].isPlayed == false, "This player has already played");
        require(idx == 0 || idx == 1, "Invalid player index");
        commit(getHash(hashed_salted_choice));
        numInput++;
        lastActionTime = block.timestamp;
    }


    // Reveal Choice
    function revealChoice(
        uint64 choice,
        string memory salt,
        uint256 idx
    ) public {
        require(numPlayer == 2, "Only playable if there are 2 players in total");
        require(msg.sender == player[idx].addr);
        require(idx == 0 || idx == 1, "Invalid player index");
        require(choice >= 0 && choice <= 6);
        bytes32 encodedSalt = bytes32(abi.encodePacked(salt));
        reveal(keccak256(abi.encodePacked(choice, encodedSalt)));
        player[idx].choice = choice;
        numShowedChoices++;
        emit RevealChoice(idx, choice);
        lastActionTime = block.timestamp;
        if (numShowedChoices == 2) {
            _checkWinnerAndPay();
        }
    }

    event RevealChoice(uint256 idx, uint256 choice);

    function _checkWinnerAndPay() private {
        uint64 p0Choice = player[0].choice;
        uint64 p1Choice = player[1].choice;
        uint64 diff = ( p1Choice + 7 - p0Choice ) % 7;
        address payable account0 = payable(player[0].addr);
        address payable account1 = payable(player[1].addr);
        uint256 winner; // Winner Value & Meaning : 0 = player 0 wins, 1 = player 1 wins, 2 = draw

        if (diff == 0) {
            // to split reward
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
            winner = 2;
        }
        else if (diff > 3) {
            // to pay player[1]
            account1.transfer(reward);
            winner = 1;
        }
        else if (diff <= 3) {
            // to pay player[0]
            account0.transfer(reward);    
            winner = 0;
        }
        emit Winner(winner,p0Choice,p1Choice);
        _resetGame();
    }

    event Winner(uint256 Winner, uint64 p0Choice, uint64 p1Choice);


    function gameUncomplete_returnMoney() public {
        // Timeout!
        require(block.timestamp - lastActionTime > ALLOWED_IDLE_TIME, "Still have time left!!!");
        require(numPlayer > 0, "There's no player in this game!");
        address payable account0 = payable(player[0].addr);
        address payable account1 = payable(player[1].addr);
        
        // return money if there's only one player has joined
        if (numPlayer == 1) {
            account0.transfer(reward);
            _resetGame();
        }

        // return money if both players not input their choice in time
        else if (numPlayer == 2 && numInput == 0) {
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
            _resetGame();
        }
        // return money if both players not revealed their choice in time
        else if (numPlayer == 2 && numInput == 2 && numShowedChoices == 0) {
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
            _resetGame();
        }
        // punish player who not input their choice in time
        else if (numPlayer == 2 && numInput == 1) {
            if (player[0].isPlayed == false) {
                // player 0 has not input their choice 
                account1.transfer(reward);
            } else if (player[1].isPlayed == false) {
                // player 1 has not input their choice
                account0.transfer(reward);
            }
            _resetGame();
        }
        // punish player who not revealed their choice in time
        else if (numPlayer == 2 && numShowedChoices == 1) {
            if (player[0].choice == 7) {
                // player 0 has not revealed their choice
                account1.transfer(reward);
            } else if (player[1].choice == 7) {
                // player 1 has not revealed their choice
                account0.transfer(reward);
            }
            _resetGame();
        }
    }
}
