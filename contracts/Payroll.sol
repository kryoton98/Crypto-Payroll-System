// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Payroll is Ownable, ReentrancyGuard {

    struct Employee {
        address walletAddress;
        uint256 monthlySalary; // in wei
        uint256 lastPaidDate;
        bool isActive;
    }

    mapping(address => Employee) public employees;
    address[] public employeeAddresses;

    event EmployeeAdded(address indexed employee, uint256 salary);
    event EmployeeRemoved(address indexed employee);
    event SalaryUpdated(address indexed employee, uint256 newSalary);
    event PaymentMade(address indexed employee, uint256 amount, uint256 timestamp);
    event ContractFunded(address indexed funder, uint256 amount);

    constructor() {}

    // Add new employee
    function addEmployee(address _wallet, uint256 _salary) external onlyOwner {
        require(_wallet != address(0), "Invalid wallet address");
        require(_salary > 0, "Salary must be greater than 0");
        require(!employees[_wallet].isActive, "Employee already exists");

        employees[_wallet] = Employee({
            walletAddress: _wallet,
            monthlySalary: _salary,
            lastPaidDate: 0,
            isActive: true
        });

        employeeAddresses.push(_wallet);
        emit EmployeeAdded(_wallet, _salary);
    }

    // Remove employee
    function removeEmployee(address _wallet) external onlyOwner {
        require(employees[_wallet].isActive, "Employee does not exist");

        employees[_wallet].isActive = false;
        emit EmployeeRemoved(_wallet);
    }

    // Update employee salary
    function updateSalary(address _wallet, uint256 _newSalary) external onlyOwner {
        require(employees[_wallet].isActive, "Employee does not exist");
        require(_newSalary > 0, "Salary must be greater than 0");

        employees[_wallet].monthlySalary = _newSalary;
        emit SalaryUpdated(_wallet, _newSalary);
    }

    // Pay single employee
    function payEmployee(address _wallet) external onlyOwner nonReentrant {
        Employee storage emp = employees[_wallet];
        require(emp.isActive, "Employee does not exist");
        require(address(this).balance >= emp.monthlySalary, "Insufficient contract balance");

        emp.lastPaidDate = block.timestamp;
        payable(_wallet).transfer(emp.monthlySalary);

        emit PaymentMade(_wallet, emp.monthlySalary, block.timestamp);
    }

    // Pay all active employees
    function payAllEmployees() external onlyOwner nonReentrant {
        uint256 totalPayment = 0;

        // Calculate total payment needed
        for (uint256 i = 0; i < employeeAddresses.length; i++) {
            address empAddress = employeeAddresses[i];
            if (employees[empAddress].isActive) {
                totalPayment += employees[empAddress].monthlySalary;
            }
        }

        require(address(this).balance >= totalPayment, "Insufficient contract balance");

        // Make payments
        for (uint256 i = 0; i < employeeAddresses.length; i++) {
            address empAddress = employeeAddresses[i];
            Employee storage emp = employees[empAddress];

            if (emp.isActive) {
                emp.lastPaidDate = block.timestamp;
                payable(empAddress).transfer(emp.monthlySalary);
                emit PaymentMade(empAddress, emp.monthlySalary, block.timestamp);
            }
        }
    }

    // Get employee count
    function getEmployeeCount() external view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < employeeAddresses.length; i++) {
            if (employees[employeeAddresses[i]].isActive) {
                count++;
            }
        }
        return count;
    }

    // Get all active employee addresses
    function getActiveEmployees() external view returns (address[] memory) {
        uint256 activeCount = 0;

        // Count active employees
        for (uint256 i = 0; i < employeeAddresses.length; i++) {
            if (employees[employeeAddresses[i]].isActive) {
                activeCount++;
            }
        }

        // Create array of active employees
        address[] memory activeEmployees = new address[](activeCount);
        uint256 index = 0;

        for (uint256 i = 0; i < employeeAddresses.length; i++) {
            if (employees[employeeAddresses[i]].isActive) {
                activeEmployees[index] = employeeAddresses[i];
                index++;
            }
        }

        return activeEmployees;
    }

    // Get employee details
    function getEmployee(address _wallet) external view returns (
        address walletAddress,
        uint256 monthlySalary,
        uint256 lastPaidDate,
        bool isActive
    ) {
        Employee memory emp = employees[_wallet];
        return (emp.walletAddress, emp.monthlySalary, emp.lastPaidDate, emp.isActive);
    }

    // Fund contract
    receive() external payable {
        emit ContractFunded(msg.sender, msg.value);
    }

    // Get contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
