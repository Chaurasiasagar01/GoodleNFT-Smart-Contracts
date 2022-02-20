import '@nomiclabs/hardhat-ethers';
import '@openzeppelin/hardhat-upgrades';
import 'hardhat-contract-sizer';
import '@typechain/hardhat';
import 'solidity-coverage';

module.exports = {
  defaultNetwork: "bsc_test",
  networks: {
    hardhat: {
    },
    local: {
      url: 'http://127.0.0.1:8545/',
      chainId: 31337,
  },
    bsc_test: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: ["714345fc9749bb1d8044b6ce906d775b6dae9affcafa98c182323dd82cf7fb43"]
    },
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: ["714345fc9749bb1d8044b6ce906d775b6dae9affcafa98c182323dd82cf7fb43"]
    }
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  }
}