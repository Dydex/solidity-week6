// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MultiSigFactory} from "../src/MultiSigFactory.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract MultiSigFactoryTest is Test {
    MultiSigFactory factory;
    MultiSigWallet wallet;

    address owner = address(msg.sender);

    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(3);
    address user4 = address(4);
    address zeroAddress = address(0);

    function setUp() public {
        factory = new MultiSigFactory();
    }

    function testCreateNewWallet() public {
        factory.createNewMultiSigWallet(3, 5);

        address[] memory wallets = factory.getAllWallets();

        assertEq(wallets.length, 1);

        wallet = MultiSigWallet(wallets[0]);

        assertEq(wallet.quorum(), 3);
        assertEq(wallet.totalSignatories(), 5);
    }

    function testDeposit() public {
        factory.createNewMultiSigWallet(3, 5);
        address walletAddress = factory.getAllWallets()[0];
        wallet = MultiSigWallet(walletAddress);
        hoax(user1, 4 ether);
        wallet.deposit{value: 1 ether}();
        assertEq(address(wallet).balance, 1 ether);
    }

    function testOwnerIsFactoryCaller() public {
        factory.createNewMultiSigWallet(3, 5);
        address walletAddress = factory.getAllWallets()[0];
        wallet = MultiSigWallet(walletAddress);
        assertEq(wallet.owner(), address(factory));
    }

    function testAddCoSigners() public {
        factory.createNewMultiSigWallet(3, 5);
        address walletAddres = factory.getAllWallets()[0];
        wallet = MultiSigWallet(walletAddres);

        
        address [4] memory signers = [user1,user2,user3,user4];
        vm.startPrank(owner);
        wallet.addCosigners(signers);

        assertTrue(wallet.isValid(user1));
        assertTrue(wallet.isValid(user2));
        assertTrue(wallet.isValid(user3));
        assertTrue(wallet.isValid(user4));

        assertEq(wallet.cosigners(0), user1);
        vm.stopPrank();
    }
}
