const hre = require("hardhat");

async function main() {
  const Journal = await hre.ethers.getContractFactory("DailyJournal");
  const journal = await Journal.deploy();

  await journal.waitForDeployment();

  console.log("Deployed to:", await journal.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
