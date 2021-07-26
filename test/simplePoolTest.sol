// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MyToken.sol";
import "../contracts/Pool.sol";

contract TestPool {
 // The address of the adoption contract to be tested

  function testInitialMyTokenBalance() public {
    MyToken projectToken = MyToken(DeployedAddresses.MyToken());
    
    uint expected = 1000;

    Assert.equal(projectToken.balanceOf(DeployedAddresses.MyToken()), expected, "MyToken should have 1000 tokens initially");
  }
}
