pragma solidity ^0.4.15;

import "./BallotBox.sol";
import "./Bonding.sol";

contract Demos is BallotBox, Bonding {

  uint public ballotIndex = 0;
  uint public interestRate = 10**16; //1% interest rate on weekly votes
  uint public bondedTarget = 5*(10**17);// 50%
  uint constant rateFactor = 10**18;
  uint public votingTime = 7 days;

  mapping (address => uint) public voted;

  function submitVote(bool[] vote) public {
    if (voted[msg.sender] == ballotIndex) return;
    if (block.timestamp > (current.startTime + votingTime)) return;
    for (uint i=0; i<current.numInits; i++) {
      if (vote[i]) {
        current.inits[i].votes += bonded[msg.sender];
      }
    }
    uint payment = (bonded[msg.sender]*interestRate)/rateFactor;
    mintFor(payment, msg.sender, true);
    voted[msg.sender] = ballotIndex;
  }
}
