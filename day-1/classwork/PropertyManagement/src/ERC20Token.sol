// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol"; 

contract ERC20Token is ERC20 {

    constructor() ERC20("Dolapo", "Dp"){
    }

    function mint(uint amount)external {

        _mint(msg.sender, uint amount);
        
    }
}