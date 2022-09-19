import * as dotenv from 'dotenv';
dotenv.config();

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@typechain/hardhat'
import '@nomiclabs/hardhat-ethers'
import "hardhat-preprocessor";
import "hardhat-gas-reporter"
import fs from 'fs';

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          getRemappings().forEach(([find, replace]) => {
            if (line.match(find)) {
              line = line.replace(find, replace);
            }
          });
        }
        return line;
      },
    }),
  },
  paths: {
    sources: "./src",
    cache: "./cache_hardhat",
  },
  gasReporter: {
    enabled: (process.env.REPORT_GAS) ? true : false,
    coinmarketcap: process.env.COINMARKETCAP,
    currency: "USD",
  }
};

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line) => line.trim().split("="));
}

export default config;
