// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MultiSigWallet {
    address[] public cosigners;
    uint8 public quorum;
    uint8 public totalSignatories;
    uint8 public Signatures;
    address public owner;

    struct Transaction {
        address receipent;
        uint256 amount;
    }

    mapping(address => bool) public isValid;

    Transaction public transactions;

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert Unauthorized();
        }
        _;
    }

    constructor(uint8 _quorum, uint8 _totalSignatories, address _owner) {
        owner = _owner;
        cosigners.push(owner);
        isValid[msg.sender] = true;

        totalSignatories = _totalSignatories;
        quorum = _quorum;
    }

    error Unauthorized();
    error InvalidAmount();
    error ExceededAddress();
    error InvalidSigner();
    error TransactionFailed();
    error InvalidAddress();

    function deposit() external payable {
        require(msg.value > 0, "Invalid Amount");
    }

    function addCosigners(address[4] calldata _cosigners) external onlyOwner {
        for (uint8 i = 0; i < _cosigners.length; i++) {
            if (_cosigners.length > totalSignatories) {
                revert ExceededAddress();
            } else if (_cosigners[i] == address(0)) {
                revert InvalidAddress();
            } 
            else {
                cosigners.push(_cosigners[i]);
                isValid[_cosigners[i]] = true;
            }
        }
    }

    function changeOwner(address _newOwner) external onlyOwner {
        if (!isValid[msg.sender]) {
            revert InvalidSigner();
        } else {
            Signatures += 1;
        }

        if (Signatures == quorum) {
            owner = _newOwner;

            Signatures = 0;
        }

        if (msg.sender != owner) {
            revert Unauthorized();
        }
    }

    function createTransaction(address _receipent, uint256 _amount) external {
        if (_amount < 0) {
            revert InvalidAmount();
        }

        transactions.receipent = _receipent;
        transactions.amount = _amount;
    }

    function signTransaction() external {
        if (!isValid[msg.sender]) {
            revert InvalidSigner();
        } else {
            Signatures += 1;
        }

        if (Signatures == quorum) {
            (bool success,) = payable(transactions.receipent).call{value: transactions.amount}("");
            if (!success) revert TransactionFailed();

            Signatures = 0;
            delete transactions.receipent;
            delete transactions.amount;
        }
    }

    function getSignatories() external view returns (address[] memory) {
        return cosigners;
    }
}
