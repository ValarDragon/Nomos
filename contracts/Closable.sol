pragma solidity ^0.4.15;

contract Closable {
  bool closed = false;
  bool allowedToClose = false;
  uint closeAfter;

  function close() internal {
    closed = true;
  }

  function allowClose(uint blocknum) internal {
    allowedToClose = true;
    closeAfter = blocknum;
  }

  function triggerClose() public {
    if (!allowedToClose) return;
    if (block.number < closeAfter) return;
    closed = true;
  }

  modifier notClosed() {
    require(!closed);
    _;
  }

  modifier isClosed() {
    require(closed);
    _;
  }
}
