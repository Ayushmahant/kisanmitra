const hre = require("hardhat");

async function main() {
  const SimpleContract = await hre.ethers.getContractFactory("SimpleContract");
  const contract = await SimpleContract.deploy();

  console.log("Deploying contract...");
  await contract.waitForDeployment(); // ✅ Use this instead of contract.deployed()

  console.log("Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
