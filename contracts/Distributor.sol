pragma solidity ^0.4.15;

import "tokens/StandardToken.sol";
import "./Bonding.sol";

contract Distributor is StandardToken, Bonding {
  /*
  Base contract for distributor systems
  Allows users to buy and sell tokens at a market price,
  which increases to infinity as share of tokens held by contract goes to zero.
  Idea is that more tokens are distributed as market value of system goes up.
  In theory this should help reduce FOMO and lead to a more balanced distribution of ownership.

  Contract should always hold enough Ether to buyback all tokens held by users.
  Extending contracts are expected to maintain invariant:
  deposits[this] = scale * ((totalSupply / balances[this]) - 1)
  */

  uint public scale; //eth owned by contract when 50% of tokens are distributed (in wei uints)
  uint public scaledSupply;

  mapping (address => uint) public deposits;

  function Distributor(uint scale_, uint totalSupply_) {
    scale = scale_;
    totalSupply = totalSupply_;
    balances[this] = totalSupply;
    deposits[this] = 0;
    scaledSupply = scale*totalSupply;
  }

  function deposit() payable public {
    deposits[msg.sender] += msg.value;
  }
  function depositOf(address _owner) constant returns (uint256 depo) {
      return deposits[_owner];
  }

  function withdraw(uint amount) public {
    require(deposits[msg.sender] < amount);
    deposits[msg.sender] -= amount;
    msg.sender.transfer(amount);
  }

  /*
  Mints new coins and gives them to receiver.
  Also mints an amount of new coins for the contract, to maintain invariant.

  Intended to be used for project funding / grants.
  */
  function mintFor(uint amount, address receiver, bool isBonded) internal {
    uint toContract = ((amount * balances[this]) / (totalSupply - balances[this]));
    totalSupply += (amount + toContract);
    balances[this] += toContract;
    if (isBonded) bonded[receiver] += amount;
    else balances[receiver] += amount;
    scaledSupply = scale * totalSupply;
    Transfer(address(0), this, toContract+amount);
    Transfer(this, receiver, amount);
  }
}
