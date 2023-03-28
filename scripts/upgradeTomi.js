const { ethers, upgrades } = require("hardhat");

async function main() {
  const DaoPublic = await ethers.getContractFactory(
    "DaoPublic"
  );
  console.log("Upgrading DaoPublic...");
  await upgrades.upgradeProxy(
    "0x927B8c62E1d85A99F6537F8182Ee44fB964C9611", // old address
    DaoPublic
  );
  console.log("Upgraded Successfully");
}

main();