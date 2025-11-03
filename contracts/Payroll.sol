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
    address[] private employeeAddresses;

    event EmployeeAdded(address indexed employee, uint256 salary);
    event EmployeeRemoved(address indexed employee);
    event SalaryUpdated(address indexed employee, uint256 newSalary);
    event PaymentMade(address indexed employee, uint256 amount, uint256 timestamp);
    event ContractFunded(address indexed funder, uint256 amount);

    // ✅ FIX: Pass msg.sender to Ownable constructor
    constructor() Ownable(msg.sender) {}

    // ------------------------------
    // 🔹 EMPLOYEE MANAGEMENT
    // ------------------------------

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

    function removeEmployee(address _wallet) external onlyOwner {
        Employee storage emp = employees[_wallet];
        require(emp.isActive, "Employee not active");
        emp.isActive = false;
        emit EmployeeRemoved(_wallet);
    }

    function updateSalary(address _wallet, uint256 _newSalary) external onlyOwner {
        Employee storage emp = employees[_wallet];
        require(emp.isActive, "Employee not active");
        require(_newSalary > 0, "Invalid salary");
        emp.monthlySalary = _newSalary;
        emit SalaryUpdated(_wallet, _newSalary);
    }

    // ------------------------------
    // 💸 PAYMENTS
    // ------------------------------

    function payEmployee(address _wallet) external onlyOwner nonReentrant {
        Employee storage emp = employees[_wallet];
        require(emp.isActive, "Employee not active");
        require(address(this).balance >= emp.monthlySalary, "Insufficient balance");

        emp.lastPaidDate = block.timestamp;

        (bool success, ) = payable(_wallet).call{value: emp.monthlySalary}("");
        require(success, "Payment failed");

        emit PaymentMade(_wallet, emp.monthlySalary, block.timestamp);
    }

    function payAllEmployees() external onlyOwner nonReentrant {
        uint256 timestamp = block.timestamp;

        for (uint256 i = 0; i < employeeAddresses.length; i++) {
            address empAddr = employeeAddresses[i];
            Employee storage emp = employees[empAddr];

            if (emp.isActive && emp.monthlySalary > 0) {
                require(address(this).balance >= emp.monthlySalary, "Insufficient funds");

                emp.lastPaidDate = timestamp;
                (bool success, ) = payable(empAddr).call{value: emp.monthlySalary}("");
                require(success, "Payment failed");

                emit PaymentMade(empAddr, emp.monthlySalary, timestamp);
            }
        }
    }

    // ------------------------------
    // 📊 VIEWS
    // ------------------------------

    function getEmployeeCount() external view returns (uint256 count) {
        for (uint256 i = 0; i < employeeAddresses.length; i++) {
            if (employees[employeeAddresses[i]].isActive) count++;
        }
        return count;
    }

    function getActiveEmployees() external view returns (address[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < employeeAddresses.length; i++) {
            if (employees[employeeAddresses[i]].isActive) activeCount++;
        }

        address[] memory activeList = new address[](activeCount);
        uint256 index = 0;

        for (uint256 i = 0; i < employeeAddresses.length; i++) {
            if (employees[employeeAddresses[i]].isActive) {
                activeList[index++] = employeeAddresses[i];
            }
        }

        return activeList;
    }

    function getEmployee(address _wallet)
        external
        view
        returns (
            address walletAddress,
            uint256 monthlySalary,
            uint256 lastPaidDate,
            bool isActive
        )
    {
        Employee memory emp = employees[_wallet];
        return (emp.walletAddress, emp.monthlySalary, emp.lastPaidDate, emp.isActive);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // ------------------------------
    // ⚙️ FUNDING
    // ------------------------------

    receive() external payable {
        emit ContractFunded(msg.sender, msg.value);
    }
}
