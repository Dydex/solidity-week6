// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract MultiSigWallet {
    address[] public cosigners;
    uint8 public quorum;
    uint8 public totalSignatories;
    uint8 public Signatures;
    address public owner;

    struct Transaction {
        address receipent;
        uint amount;
    }

    mapping(address => bool) public isValid;

    Transaction[] public transactions;

    modifier onlyOwner() {
        if (owner != msg.sender) 
        revert Unauthorized();
        _;
    }

    constructor(address _quorum, uint8 totalSignatories) {
        owner = msg.sender;
        isValid[msg.sender] = true;

        quorum = _quorum;
    }

    uint public TransactionId;

    error Unauthorized();
    error InvalidAmount();
    error ExceededAddress();
    error InvalidSigner();
    error TransactionFailed(); 

    function addCosigners(address[4] _cosigners) external onlyOwner {

        for (uint8 i = 0; i <= _cosigners.length; i++ ) {
            if (_cosigners.length > totalSignatories) {
                revert ExceededAddress();
            } else {
                cosigners.push(_cosigners[i]);
                isValid[_cosigners[i]] = true;
            }         
        }
        
    } 

    function changeOwner(address _newOwner) external onlyOwner{
         if(!isValid[msg.sender]){
            revert InvalidSigner();
        } else {
            Signatures += 1;
        }

        if(Signatures == quorum){
            owner = _newOwner;

            Signatures = 0; 
        }

        if(msg.sender != owner)
        revert Unauthorized();

       
    } 

    function transaction(address _receipent, uint _amount) external {
        if(_amount < 0) 
        revert InvalidAmount() ;

        Transaction memory transaction = Transaction(_receipent, _amount);
        transactions.push(transaction);
    }

    function signTransaction() external {
        if(!isValid[msg.sender]){
            revert InvalidSigner();
        } else {
            Signatures += 1;
        }

        if(Signatures == quorum){
            (bool success,) = payable(transactions.receipent).call{value: transactions.amount}("");
            if(!success) revert TransactionFailed();

            Signatures = 0; 
        }
    } 

    function getSignatories() external view returns(address[]) {
        return cosigners;
    }

}
