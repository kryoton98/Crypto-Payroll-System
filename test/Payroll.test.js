const { expect } = require("chai");

describe("Payroll Contract", function () {
  it("Should deploy and add employee", async function () {
    const Payroll = await ethers.getContractFactory("Payroll");
    const payroll = await Payroll.deploy();
    await payroll.waitForDeployment();

    const [owner, emp1] = await ethers.getSigners();
    await payroll.addEmployee(emp1.address, ethers.parseEther("0.1"));
    const emp = await payroll.employees(emp1.address);
    expect(emp.salary.toString()).to.equal(ethers.parseEther("0.1").toString());
  });
});
