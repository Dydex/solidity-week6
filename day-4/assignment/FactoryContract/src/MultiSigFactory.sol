// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./MultiSigWallet.sol";

contract MultiSigFactory {
    MultiSigWallet[] public multiSigWallets;
    address[] addressMultiSigwallets;

    function createNewMultiSigWallet(uint8 _quorum, uint8 _totalSignatories) external {
        MultiSigWallet wallet = new MultiSigWallet(_quorum, _totalSignatories, msg.sender);
        multiSigWallets.push(wallet);
        addressMultiSigwallets.push(address(wallet));
    }

    function getAllWallets() external view returns (address[] memory) {
        return addressMultiSigwallets;
    }
}
