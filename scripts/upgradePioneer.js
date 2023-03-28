const { ethers, upgrades } = require("hardhat");

async function main() {
  const DaoCommittee = await ethers.getContractFactory(
    "DaoCommittee"
  );
  console.log("Upgrading DaoCommittee...");
  await upgrades.upgradeProxy(
    "0x7Bc16aB8336677feC6F1BDB6C22d731966255304", // old address
    DaoCommittee
  );
  console.log("Upgraded Successfully");
}

main();