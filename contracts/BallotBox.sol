pragma solidity ^0.4.15;

import "./Executive.sol";
import "./Admin.sol";

contract BallotBox is Executive, Admin {
  /*
  two ballot system, live and future

  a bunch of admin only functions to add things to the future ballot
  and a turnkey function to make the future ballot the current ballot

  also reminds me that i should consider making it possible to have multiple proposers...


  */

  struct Ballot {
    Initiative[] inits;
    uint numInits;
    uint startTime;
  }

  struct Initiative {
    Executable e;
    Quora q;
    uint votes;
  }

  Ballot public current;
  Ballot public future;

  function proposeSetEthUsdRate(uint rate) public onlyAdmin {
    bytes memory b = new bytes(32);
    write32(b,bytes32(rate),0);
    future.inits[future.numInits++] = Initiative(Executable(Actions.setEthUsdRate, b), Quora.majorityBonded, 0);
  }

  //other proposals for setting variables here... TODO

  function proposeCreateMint(address receiver, uint amount, Units unit, uint period, int limit) public onlyAdmin {
    bytes memory b = new bytes(117);
    write20(b,bytes20(receiver),0);
    write32(b,bytes32(amount),20);
    write1(b,bytes1(uint8(unit)),52);
    write32(b,bytes32(period),53);
    write32(b,bytes32(limit),85);
    future.inits[future.numInits++] = Initiative(Executable(Actions.createMint, b), Quora.majorityIssued, 0);
  }

  function proposeCloseContract(uint blocknum) public onlyAdmin {
    bytes memory b = new bytes(32);
    write32(b,bytes32(blocknum),0);
    future.inits[future.numInits++] = Initiative(Executable(Actions.closeContract, b), Quora.superMajorityTotal, 0);
  }

  function executeBallot() internal {
    for (uint i=0; i<current.numInits; i++) {
      Initiative storage init = current.inits[i];
      if (checkVotes(init.q, init.votes)) {
        execute(init.e);
      }
    }
  }

  function activateBallot() internal {
    delete current;
    current.inits = future.inits;
    current.numInits = future.numInits;
    current.startTime = block.timestamp;
    delete future;
  }

  function cycleBallots() public onlyAdmin {
    if (block.timestamp < (current.startTime + votingTime)) return;
    executeBallot();
    activateBallot();
  }
}
