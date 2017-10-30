pragma solidity ^0.4.15;

contract BytesLib {

  function read32(bytes b, uint offset) constant returns (bytes32) {
    uint dat;
    for (uint8 i=0; i<32; i++) {
      dat ^= (uint(b[offset+i]) << (8*(31-i)));
    }
    return bytes32(dat);
  }

  function read20(bytes b, uint offset) constant returns (bytes20) {
    uint dat;
    for (uint8 i=0; i<20; i++) {
      dat ^= (uint(b[offset+i]) << (8*(19-i)));
    }
    return bytes20(dat);
  }

  function read1(bytes b, uint offset) constant returns (bytes1) {
    return bytes1(uint(b[offset]));
  }

  function write32(bytes b, bytes32 t, uint offset) {
    for (uint8 i=0; i<32; i++) {
      b[offset+i] = t[i];
    }
  }

  function write20(bytes b, bytes20 t, uint offset) {
    for (uint8 i=0; i<20; i++) {
      b[offset+i] = t[i];
    }
  }

  function write1(bytes b, bytes1 t, uint offset) {
    b[offset] = t[0];
  }
}
