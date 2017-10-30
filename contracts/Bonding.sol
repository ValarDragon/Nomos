pragma solidity ^0.4.15;

contract Bonding {

  struct Unbond {
    uint amount;
    uint finishedTime;
  }

  uint public totalBonded;
  uint public unbondingTime = 14 days;
  mapping (address => uint) public balances;
  mapping (address => uint) public bonded;
  mapping (address => Unbond) public unbonding;

  function bond(uint amount) public {
    if (balances[msg.sender] < amount) return;
    bonded[msg.sender] += amount;
    balances[msg.sender] -= amount;
    totalBonded += amount;
  }

  function beginUnbonding(uint amount) public {
    if (bonded[msg.sender] < amount) return;
    if (unbonding[msg.sender].finishedTime != 0) return;
    unbonding[msg.sender] = Unbond(amount, block.timestamp + unbondingTime);
  }

  function cancelUnbonding() public {
    bonded[msg.sender] += unbonding[msg.sender].amount;
    delete unbonding[msg.sender];
  }

  function finishUnbonding() public {
    if (unbonding[msg.sender].finishedTime < block.timestamp) return;
    balances[msg.sender] += unbonding[msg.sender].amount;
    totalBonded -= unbonding[msg.sender].amount;
    delete unbonding[msg.sender];
  }
}
