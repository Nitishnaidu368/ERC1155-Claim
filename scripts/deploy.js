// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const NFT1155Drop = await hre.ethers.getContractFactory("NFT1155Drop");
  const instance = await NFT1155Drop.deploy("0x7aa0a18f56CfBdBAf3dFF7A97BB56E32fdCC66e1", "0xc6127eA3089fAE66394864f9a370Df9dc7bA1CFC");

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
