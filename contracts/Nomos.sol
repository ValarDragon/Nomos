pragma solidity ^0.4.15;


import "./AsyncBatchedDistributor.sol";
import "./Demos.sol";

contract Nomos is AsyncBatchedDistributor, Demos{

  string public constant symbol = "NOM";
  string public constant name = "Nomos Network Token";
  uint public constant decimals = 18;

  function Nomos() AsyncBatchedDistributor((2**15)*(10**18), 10**27) {
    //
  }
}
