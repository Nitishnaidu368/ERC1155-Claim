require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config()

const pk = process.env.PK;
const polygon = process.env.POLYGON_SCAN;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.2",
  networks: {
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [pk]
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: polygon,
    }
  },
  paths : {
    //artifacts: './frontend/src/artifacts'
  }
};
