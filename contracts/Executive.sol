pragma solidity ^0.4.15;

import "./Treasury.sol";
import "./BytesLib.sol";
import "./Closable.sol";

contract Executive is Treasury, BytesLib, Closable {

  uint public ethUsdRate;
  uint public bondedTarget;
  uint public unbondingTime;
  uint public votingTime;

  uint totalBonded;
  uint totalSupply;
  mapping (address => uint) public balances;

  function majority(uint votes, uint possible) constant returns (bool) {
    return (2*votes) > possible;
  }

  function superMajority(uint votes, uint possible) constant returns (bool) {
    return ((3*votes)/2) > possible;
  }

  enum Quora {
    majorityBonded, superMajorityBonded, majorityIssued,
    superMajorityIssued, majorityTotal, superMajorityTotal
  }

  function checkVotes(Quora quorum, uint votes) constant returns (bool) {
    if (quorum == Quora.majorityBonded) return majority(votes, totalBonded);
    else if (quorum == Quora.superMajorityBonded) return superMajority(votes, totalBonded);
    else if (quorum == Quora.majorityIssued) return majority(votes, totalSupply-balances[this]);
    else if (quorum == Quora.superMajorityIssued) return superMajority(votes, totalSupply-balances[this]);
    else if (quorum == Quora.majorityTotal) return majority(votes, totalSupply);
    else if (quorum == Quora.superMajorityTotal) return superMajority(votes, totalSupply);
  }

  enum Actions {
    setEthUsdRate, setBondedTarget, setUnbondingTime,
    setVotingTime, createMint, closeContract
  }

  struct Executable {
    Actions action;
    bytes args;
  }


  function execute(Executable e) internal {
    if (e.action == Actions.setEthUsdRate) {
      ethUsdRate = uint(read32(e.args,0));
    }
    else if (e.action == Actions.setBondedTarget) {
      bondedTarget = uint(read32(e.args,0));
    }
    else if (e.action == Actions.setUnbondingTime) {
      unbondingTime = uint(read32(e.args,0));
    }
    else if (e.action == Actions.setVotingTime) {
      votingTime = uint(read32(e.args,0));
    }
    else if (e.action == Actions.createMint) {
      addMint(address(read20(e.args,0)), uint(read32(e.args,20)),
        Units(uint8(read1(e.args,52))), uint(read32(e.args,53)), int(read32(e.args,85)));
    }
    else if (e.action == Actions.closeContract) {
      allowClose(uint(read32(e.args,0)));
    }
  }
}
