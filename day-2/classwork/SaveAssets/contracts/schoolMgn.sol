// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./IERC20.sol";

contract SchoolMgn {
    IERC20 public token;

    uint public studentId;
    uint public staffId;
    address public principal;

    struct Student {
        uint id;
        string name;
        uint level; 
        uint fee;
        bool paid; 
        uint timePaid;
    }

    struct Staff {
        uint staffid;
        string name;
        uint level;
        uint salary;
        address walletAddress;
    }

    mapping(uint => uint) public levelFees;
    mapping(uint => uint) public levelSalary;
    mapping(address => uint) public schoolFees;
    mapping(address => bool) public staffAddress;
    mapping(address => bool) public paidSalary;
    mapping(uint => bool) public isSuspended;

    Student[] public students;
    Staff[] public staffs;

    modifier onlyPrincipal() {
        require(msg.sender == principal, "You are not the Principal");
        _;
    }

    constructor(address _tokenAddress){

        token = IERC20(_tokenAddress);

        principal = msg.sender;

        levelFees[100] = 1000 * 10**18;
        levelFees[200] = 2000 * 10**18;
        levelFees[300] = 3000 * 10**18;
        levelFees[400] = 4000 * 10**18;

        levelSalary[100] = 100 * 10**18;
        levelSalary[200] = 200 * 10**18;
        levelSalary[300] = 300 * 10**18;
        levelSalary[400] = 400 * 10**18;
    }

    function registerStudent(string memory _name, uint _level) external onlyPrincipal {
        uint _fee = levelFees[_level];  
        require(_fee > 0, "Invalid level");
        require(token.balanceOf(msg.sender) >= _fee , "Insufficient Balance");
        token.transferFrom(msg.sender, address(this), _fee);

        studentId += 1;
        Student memory student = Student(studentId, _name, _level, _fee, true, block.timestamp );
        students.push(student);
    }

    function getAllStudents() external view returns(Student[] memory){
        return students;
    }

    function removeStudent(uint studentId_) external onlyPrincipal {
        require(studentId_ > 0 && studentId_ <= students.length, "Invalid staff ID");

        for (uint i = 0; i < students.length; i++) {
            if (students[i].id == studentId_) {
                students[i] = students[students.length - 1];
                students.pop();   
            }
        }
    }

    function registerStaff(string memory _name, uint _level, address _walletAddress ) external onlyPrincipal {
        require(!staffAddress[_walletAddress], "Wallet Address Already Exists" );
        require(_walletAddress != address(0), "Invalid Address" );
        uint _salary = levelSalary[_level];

        staffId += 1;
        Staff memory staff = Staff(staffId, _name, _level, _salary, _walletAddress);
        staffs.push(staff);
        staffAddress[_walletAddress] = true;
    }

    function getAllStaffs() external view returns(Staff[] memory) {
        return staffs;
    }
    
    function payStaff(uint _staffId, uint _level, address _walletAddress) external onlyPrincipal {
        require(_level  == 100 || _level == 200 || _level == 300 || _level == 400, "Invalid Level");
        require(_walletAddress != address(0), "Invalid Address" );
        require(!paidSalary[_walletAddress], "Already paid Salary" );
        require(!isSuspended[_staffId], "Staff is Suspended");

        uint salary = levelSalary[_level]; 
        require(token.balanceOf(address(this)) >= salary, "Insufficient balance");
        token.transfer(_walletAddress, salary);
        paidSalary[_walletAddress] = true; 
    }   

    function suspendStaff(uint _staffId) external onlyPrincipal {
       require(_staffId > 0 && _staffId <= staffs.length, "Invalid staff ID");
       require(!isSuspended[_staffId], "Staff is Suspended");
       isSuspended[_staffId] = true;
    }  
}