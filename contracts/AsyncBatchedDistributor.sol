pragma solidity ^0.4.15;

import "./Distributor.sol";

contract AsyncBatchedDistributor is Distributor {
  /*
  Attempts to solve the frontrunning problems of FIFODistributor,
  while also solving the problems of having a user execute the batch clearing.

  In this system users submit orders,
  then in a future block they submit another transaction to claim that order.
  This breaks the linear cost of batch clearing into constant cost for each user.

  Also the use of prices, totalEthIn, and totalTokensIn as mappings,
  from block number to value, allows automatic retention of historical price/volume data.

  Worth noting that this is still manipulable by miners,
  but it would require selfish mining at least 3 blocks in a row.
  So as to separate out the 3 sets of transactions:
  miner buy, natural user buys, miner sell.
  (or the inverse with user sells)

  extending the window across multiple blocks would also make manipulation harder.
  */

  event Debug(string msg);

  struct Order {
    int amount; //positive numbers are eth sold for tokens, negative are tokens sold for eth.
    uint blocknum;
  }

  uint public pendingBlock;
  uint public lastPrice;
  mapping (address => Order) public orders;
  mapping (uint => uint) public prices;
  mapping (uint => uint) public totalEthIn;
  mapping (uint => uint) public totalTokensIn;

  function AsyncBatchedDistributor(uint scale_, uint totalSupply_) Distributor(scale_, totalSupply_) {
    pendingBlock = 0;
  }

  function submitOrder(int amount) public {
    if (block.number > pendingBlock) calculatePrice();
    if (orders[msg.sender].blocknum == block.number) return; //already have an order in this block.
    if (orders[msg.sender].amount != 0) claimOrder();
    uint amt;
    if (amount > 0) {
      amt = uint(amount);
      if (deposits[msg.sender] < amt) return;
      deposits[msg.sender] -= amt;
      deposits[address(0)] += amt; //only to keep total of deposits consistent, may not be needed
      totalEthIn[block.number] += amt;
      orders[msg.sender] = Order(amount, block.number);
    } else {
      amt = uint(-amount);
      if (balances[msg.sender] < amt) return;
      balances[msg.sender] -= amt;
      balances[address(0)] += amt; //same idea wrt to balances, so that sum(balances) = totalSupply
      totalTokensIn[block.number] += amt;
      orders[msg.sender] = Order(amount, block.number);
    }
  }

  function claimOrder() public {
    Debug("in claim order");
    if (block.number > pendingBlock) calculatePrice();
    Debug("post calc price");
    Order storage order = orders[msg.sender];
    uint amt;
    if (order.amount > 0) {
      Debug("amount > 0");
      amt = uint(order.amount);
      uint tokensOut = (amt * (10**18)) / prices[order.blocknum];
      balances[msg.sender] += tokensOut;
      balances[address(0)] -= tokensOut;
    } else {
      Debug("amount < 0");
      amt = uint(-order.amount);
      uint ethOut = (prices[order.blocknum] * amt)/(10**18);
      deposits[msg.sender] += ethOut;
      deposits[address(0)] -= ethOut;
    }
    Debug("removing order");
    orders[msg.sender].amount = 0;
  }

  function calculatePrice() internal {
    Debug("calculating price");
    uint totalTokensOut = (scaledSupply/((scaledSupply/balances[this]) - totalEthIn[pendingBlock])) - balances[this];
    uint totalEthOut = (scaledSupply/(balances[this]-totalTokensOut)) -
      (scaledSupply / (balances[this] + totalTokensIn[pendingBlock] - totalTokensOut));
    int netEth = int(totalEthIn[pendingBlock]) - int(totalEthOut);
    int netTokens = int(totalTokensIn[pendingBlock]) - int(totalTokensOut);
    //if quantity exchanged matches up, contract supply is unchanged
    //price for exchange is slope of tangent line at point on tokens/eth curve.
    if (netEth == 0 || netTokens == 0) lastPrice = ((10**18)*scaledSupply)/(balances[this]**2);
    //if there is an imbalance in quantity exchanged,
    //the price is the slope of the line connecting the starting and ending points on the tokens/eth curve.
    else lastPrice = uint(((10**18)*netEth)/(-netTokens));
    prices[pendingBlock] = lastPrice;
    pendingBlock = block.number;
  }
}
