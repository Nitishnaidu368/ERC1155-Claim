// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const NFT1155Drop = await hre.ethers.getContractFactory("NFT1155Drop");
  const instance = await NFT1155Drop.deploy("0xf02c627B3Ae533D488cb25F072e542ee7CCc1D10", "0xDf9CE7eCeC9388e6A71eeA2690EA5825B7b00ca1", "0x69015912AA33720b842dCD6aC059Ed623F28d9f7");

  await instance.deployed();

  console.log(
    `instance deployed to: ${instance.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
