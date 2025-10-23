// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Payroll is Ownable {
    struct Employee {
        address wallet;
        uint256 salary;
    }
    mapping(address => Employee) public employees;

    constructor() {}

    function addEmployee(address _wallet, uint256 _salary) external onlyOwner {
        employees[_wallet] = Employee(_wallet, _salary);
    }

    function removeEmployee(address _wallet) external onlyOwner {
        delete employees[_wallet];
    }

    function payEmployee(address _wallet) external onlyOwner payable {
        require(employees[_wallet].salary > 0, "Not an employee");
        payable(_wallet).transfer(employees[_wallet].salary);
    }

    receive() external payable {}
}
