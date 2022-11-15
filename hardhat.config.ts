require("@nomicfoundation/hardhat-toolbox");
require('hardhat-contract-sizer');
require("hardhat-gas-reporter");

import fs from 'fs';
import { HardhatUserConfig, task } from 'hardhat/config';
import CollectionConfig from './config/CollectionConfig';

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

/**
 * Task 
 */
task('rename-contract', 'Renames the smart contract replacing all occurrences in source files', async (taskArgs: {newName: string}, hre) => {
  // Validate new name
  if (!/^([A-Z][A-Za-z0-9]+)$/.test(taskArgs.newName)) {
    throw 'The contract name must be in PascalCase: https://en.wikipedia.org/wiki/Camel_case#Variations_and_synonyms';
  }

  const oldContractFile = `${__dirname}/contracts/${CollectionConfig.contractName}.sol`;
  const newContractFile = `${__dirname}/contracts/${taskArgs.newName}.sol`;

  if (!fs.existsSync(oldContractFile)) {
    throw `Contract file not found: "${oldContractFile}" (did you change the configuration manually?)`;
  }

  if (fs.existsSync(newContractFile)) {
    throw `A file with that name already exists: "${oldContractFile}"`;
  }

  // Replace names in source files
  // replaceInFile(__dirname + '/../minting-dapp/src/scripts/lib/NftContractType.ts', CollectionConfig.contractName, taskArgs.newName);
  // replaceInFile(__dirname + '/config/CollectionConfig.ts', CollectionConfig.contractName, taskArgs.newName);
  // replaceInFile(__dirname + '/lib/NftContractProvider.ts', CollectionConfig.contractName, taskArgs.newName);
  // replaceInFile(oldContractFile, CollectionConfig.contractName, taskArgs.newName);

  // Rename the contract file
  // fs.renameSync(oldContractFile, newContractFile);

  console.log(`Contract renamed successfully from "${CollectionConfig.contractName}" to "${taskArgs.newName}"!`);

  // Rebuilding types
  await hre.run('typechain');
})
.addPositionalParam('newName', 'The new name');

  
/**
 * Replaces all occurrences of a string in the given file. 
 */
function replaceInFile(file: string, search: string, replace: string): void
{
  const fileContent = fs.readFileSync(file, 'utf8').replace(new RegExp(search, 'g'), replace);

  fs.writeFileSync(file, fileContent, 'utf8');
}

