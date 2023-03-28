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
 

  const Xenoverse_ = await ethers.getContractFactory("Xenoverse");
  const Xenoverse = await Xenoverse_.deploy();
  await Xenoverse.deployed();

  console.log(`Xenoverse deployed to ${Xenoverse.address}`);

  await new Promise(resolve => setTimeout(resolve, 10000));
  verify(Xenoverse.address, []);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
