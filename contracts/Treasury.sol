pragma solidity ^0.4.15;

contract Treasury {

  struct Mint {
    address receiver;
    uint amount;
    Units unit;
    uint period;
    uint lastMint;
    int limit;
  }

  mapping (uint => Mint) public mints;
  uint public numMints = 0;

  uint public lastPrice;
  uint public ethUsdRate;

  enum Units {
    ETH, USD, Tokens
  }

  function mintFor(uint amount, address receiver, bool isBonded) internal;

  function usdToEth(uint usd) public returns (uint eth) {
    return (usd * 10**18)/ethUsdRate;
  }
  function ethToTokens(uint eth) public returns (uint tokens) {
    return (eth * 10**18)/lastPrice;
    //could use a moving average here for better stability
  }

  function addMint(address receiver, uint amount, Units unit, uint period, int limit) internal {
    mints[numMints++] = Mint(receiver, amount, unit, period, 0, limit);
  }

  function executeMint(uint mintID) public {
    Mint storage mint = mints[mintID];
    if (msg.sender != mint.receiver) return;
    if (((block.timestamp - mint.lastMint) < mint.period) || mint.limit == 0) return;
    mint.limit -= 1;
    mint.lastMint = block.timestamp;
    uint amt;
    if (mint.unit == Units.USD) amt = ethToTokens(usdToEth(mint.amount));
    else if (mint.unit == Units.ETH) amt = ethToTokens(mint.amount);
    else amt = mint.amount;
    mintFor(amt, mint.receiver, false);
  }
}
