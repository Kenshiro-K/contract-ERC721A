require("@nomicfoundation/hardhat-toolbox");
require('hardhat-contract-sizer');
require("hardhat-gas-reporter");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.4",
  contractSizer: {
    alphaSort: false,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  gasReporter: {
    currency: 'JPY',
    coinmarketcap: '2a6f828a-5126-46ac-b428-2e0524572028',
    token: 'ETH',
    gasPrice: 14
  }
};
