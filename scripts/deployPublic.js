const { ethers } = require("hardhat");

const { network, run } = require("hardhat");

async function verify(address, constructorArguments) {
  console.log(`verify  ${address} with arguments ${constructorArguments.join(',')}`)
  await run("verify:verify", {
    address,
    constructorArguments
  })
}


async function main() {
  let DaoCommittee_ = "0xe93967aE53A14FA46953b629C2b7347b20451330"
  let timer_= 300
  let FIXED_DURATION= 300;
  let xeno = "0xc4C06e11D336871dE726Ead93aa7FF720Fa362f7";

  const DaoPublic = await ethers.getContractFactory(
    "DaoPublic"
  );
  console.log("Deploying DaoPublic...");
  const contract = await upgrades.deployProxy(DaoPublic, 
    [ DaoCommittee_,timer_,FIXED_DURATION, xeno], {
    initializer: "initialize",
    kind: "transparent",
  });
  await contract.deployed();
  console.log("DaoPublic deployed to:", contract.address);

  await new Promise(resolve => setTimeout(resolve, 20000));
  verify(contract.address, [])
}
main();