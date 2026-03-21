// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {DpNFT} from "../src/OnchainNft.sol";

contract CounterScript is Script {
    DpNFT public dpnft;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        dpnft = new DpNFT('DpNFT', 'DpNFT');

        vm.stopBroadcast();
    }
}
