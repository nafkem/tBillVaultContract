import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
// import "@nomiclabs/hardhat-etherscan";
import dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  defaultNetwork: "hardhat",

  networks: {     
      alfajores: {
        url: process.env.RPC,
        //@ts-ignore
        accounts: [process.env.PRIVATE_KEY],
        chainId: 44787,
      },
      // etherscan: {
      //   apikey: process.env.ETHERSCAN_API_KEY
      // }
  },
  };

export default config;