// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {ERC20Token} from "./ERC20Token.sol";


contract PropertyManagement {
    
    ERC20Token public erc20Token;
    address public owner; 

    constructor(address _tokenAddress) {
        erc20Token = ERC20Token(_tokenAddress);
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(owner == msg.sender, "Must be Owner" );
        _;
    } 
    
    struct Property {
        uint PropertyId;
        string Title;
        string PropertyType;
        string Location;
        bool isForSale;
        uint Price;
        
    }

    Property[] public properties;

    uint8 public propertyCount;
   
    function CreateProperty(string memory _title, string memory _propertyType, string memory _location, uint8 _price) external onlyOwner {
        propertyCount += 1;

        Property memory newProperties = Property (
            propertyCount,
            _title, 
            _propertyType,
            _location,
            true,
            _price
        );
        properties.push(newProperties);
    }

    function RemoveProperty(uint _propertyId) external onlyOwner {
        
        for (uint i = 0; i < properties.length; i++){
            if(properties[i].PropertyId == _propertyId){
                properties[i] = properties[properties.length - 1];

                properties.pop();
            }
        }
    }

    function GetAllProperties() external returns (Property[] memory) {
        return properties;
    }

    
    function PurchaseProperty(uint _propertyId, uint _price) external {
        require(_propertyId > 0 && _propertyId <= properties.length, "Invalid ID" );
        require(properties[_propertyId].isForSale, "Property is not for sale");
        require(properties[_propertyId].Price == _price, "Price Mismatch");

        for (uint i = 0; i < properties.length; i++){
            if(properties[i].PropertyId == _propertyId){
                properties[i].isForSale = false;
            }
        }

        erc20Token.transferFrom(msg.sender, address(this), _price);

    }
}

