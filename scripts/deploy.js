const hre = require("hardhat");

async function main() {
  const Payroll = await hre.ethers.getContractFactory("Payroll");
  const payroll = await Payroll.deploy();
  await payroll.waitForDeployment();
  console.log("Payroll contract deployed to:", await payroll.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
