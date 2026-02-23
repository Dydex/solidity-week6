// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PropertyManagement} from "../src/PropertyManagement.sol";

contract PropertyMangement is Script {
    PropertyManagement public propertymangement;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        propertymangement = new PropertyManagement();

        vm.stopBroadcast();
    }
}
