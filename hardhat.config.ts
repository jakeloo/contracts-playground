import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "hardhat-gas-reporter";

require("dotenv").config();

const config = {
  solidity: "0.8.9",
  networks: {
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  namedAccounts: {
    deployer: 0,
  },
  paths: {
    sources: "contracts",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
export default config;
