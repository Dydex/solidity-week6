// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract MultiSigWalletScript is Script {
    MultiSigWallet multisigwallet;

    uint8 private quorum_;
    uint8 private totalSignatories_;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        multisigwallet = new MultiSigWallet(3, 5);

        vm.stopBroadcast();

        return multisigwallet;
    }
}
