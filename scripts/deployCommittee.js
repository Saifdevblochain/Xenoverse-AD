const { ethers } = require("hardhat");

const { network, run } = require("hardhat");
const { Contract } = require("hardhat/internal/hardhat-network/stack-traces/model");

async function verify(address, constructorArguments) {
  console.log(`verify  ${address} with arguments ${constructorArguments.join(',')}`)
  await run("verify:verify", {
    address,
    constructorArguments
  })
}

async function main() {
  const DaoCommittee = await ethers.getContractFactory(
    "DaoCommittee"
  );
  console.log("Deploying DaoCommittee...");
  const contract = await upgrades.deployProxy(DaoCommittee, [], {
    initializer: "initialize",
    kind: "transparent",
  });
  await contract.deployed();
  console.log("DaoCommittee deployed to:", contract.address);

  await new Promise(resolve => setTimeout(resolve, 40000));
  verify(contract.address, [])
}

main();


// 0xa9C85732eC5A0C01196e9A91E92dBC38594d3F97

