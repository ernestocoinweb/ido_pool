// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint amount) ERC20("MyToken", "MTK") {
        _mint(msg.sender, amount);
    }
}