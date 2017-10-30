pragma solidity ^0.4.15;

contract Admin {

  address public admin = msg.sender;

  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  function changeAdmin(address newAdmin) public onlyAdmin {
    admin = newAdmin;
  }
}
