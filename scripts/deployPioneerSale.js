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

  const fundsWallet = "0x34136d58CB3ED22EB4844B481DDD5336886b3cec";
  const marketing = "0x34136d58CB3ED22EB4844B481DDD5336886b3cec";
  const merkleRoot = "0x609f642d28e8bd468eacd0ca80ff5ffa2e3a66b896dc947c95e6f592f14b0f09"
  const tomi = "0x6e1226FD834613e2628732fcF8b9d77d4396C0BD";
  const usdt = "0x2c05EA5C7abb21510840428EBDFCe047511E7ba1";
  const usdc = "0xb962006C2793820e7c3c026667DD57f094Dbf30b";
  const pioneer = "0x416edcE407684CCfCe333CDa2D28D7c218f8588D";
  const priceFeed = "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e";




  const SalePioneer_ = await ethers.getContractFactory("SalePioneer");
  const SalePioneer = await SalePioneer_.deploy(
    60,
    2900,
    fundsWallet,
    marketing,
    merkleRoot,
    tomi,
    usdt,
    usdc,
    pioneer,
    priceFeed);
  await SalePioneer.deployed();

  console.log(`SalePioneer deployed to ${SalePioneer.address}`);

  
  await new Promise(resolve => setTimeout(resolve, 40000));
  verify(SalePioneer.address, [60, 2900, fundsWallet, marketing, merkleRoot, tomi, usdt, usdc, pioneer, priceFeed])
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
