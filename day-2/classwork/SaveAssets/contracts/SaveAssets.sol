// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./IERC20.sol";

contract SaveAssets {

    address tokenAddress;

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    mapping(address => uint) savingsBalance;
    mapping(address => uint) savingsErc20;

    event DepositSuccessful(address from, uint depositedAmount);
    event WithdrawalSuccesful(address to, uint withdrawAmount);



    function depositEther() external payable {
        require(msg.value > 0, "Amount must be greater than zero");

       savingsBalance[msg.sender] += msg.value;  

        emit DepositSuccessful(msg.sender, msg.value);
    }

    function withdrawEther(uint _value) external {
        require(_value > 0, "Invalid amount" );
        require(_value <= savingsBalance[msg.sender], "Insufficient funds" );
       

        savingsBalance[msg.sender] -= _value;

        (bool success, ) = payable(msg.sender).call{value: _value}("");
        require(success, "Transfer failed");
       
       emit WithdrawalSuccesful(msg.sender, _value); 
    }

    function getUserSavings() external view returns(uint) {
        return savingsBalance[msg.sender];

    }

    function depositBalance() external view returns(uint) {
        return address(this).balance;
    }

    function depositErc20(uint _value) external {
        require(_value > 0 , "Invalid amount" );

        require(IERC20(tokenAddress).balanceOf(msg.sender) >= _value, "Insufficient funds");
        
        savingsErc20[msg.sender] = savingsErc20[msg.sender] + _value;

        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), _value), "deposit failed");

         emit DepositSuccessful(msg.sender, _value); 
    }

    function withdrawErc20(uint _value) external {
        require (_value > 0, "Invalid amount" );

        require (_value <= savingsErc20[msg.sender], "Insufficient funds" );

        savingsErc20[msg.sender] = savingsErc20[msg.sender] - _value;

        require(IERC20(tokenAddress).transfer(msg.sender, _value), "transfer failed");

        emit WithdrawalSuccesful(msg.sender, _value); 
    } 

    function getErc20SavingsBalance() external view returns (uint) {
        return savingsErc20[msg.sender];
    }

    receive()external payable {}
    fallback() external {}

}
