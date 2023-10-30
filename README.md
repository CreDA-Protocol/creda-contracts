# CreDA Protocol

## Dependencies

Make sure you're running a version of node compliant with the `engines` requirement in `package.json`, or install Node Version Manager [`nvm`](https://github.com/creationix/nvm) and run `nvm use` to use the correct version of node.

Requires `nodejs` ,`yarn` and `npm`.

```shell
# node -v
v16.0.0
# yarn version
yarn version v1.22.17
# npm -v
8.5.3
```


## Quick Start
```shell
# Development library installation
yarn install

# contract compilation
yarn compile

# copy .env.sample and add private key (contract ownership wallet)
cp .env.sample .env

# deploy to celo network
yarn scripts scripts/1deployUpgradeDataContract.js --network celo

# set fee default to 0 - mandatory when there is no CREDA ERC20 token on the deployment chain
yarn scripts scripts/2setFee.js --network celo

```

## CreDA contracts

| Contract     | Description                                                                                                                                                                      |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CredaCore    | CreDA **ERC20 token**. Deployed only on Arbitrum and ESC so far.                                                                                                                 |
| DataContract | The **Oracle** contract that deals with user accountsand credit scores.                                                                                                          |
| CreditNFT    | **Credit NFT** contract, into which users can mint/burn/upgrade/present their cNFT. The cNFT holds various information such as the credit score, NFT level, addresses list, etc. |

## Deployed contract addresses

| Chain       | Contract Name | Contract Address                           |
| ----------- | ------------- | ------------------------------------------ |
| ESC TestNet | DataContract  | 0x36aFfC79ABBd2F8Aaf32800A1333c524aF3bCE79 |
| Celo        | DataContract  | 0x878063db2d3d54e4F18e7bC448FA56A0e111C054 |

## Deployment scripts
The following are the deployment and parameter setting steps of celo. Specify the published blockchain network through --network. The networks supported by this project include:
- Celo
- Elastos ESC
- local

All scripts are under the *scripts/* folder.

| Script name                   | Description                                                                                                                  |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| 1deployUpgradeDataContract.js | This script deploys the DataContract contract to the chain.                                                                  |
| 2setFee.js                    | Sets the cost (ie: CREDA token fees to update a credit score) of creda calls, the default cost is 0.                         |
| 3setNode.js                   | Sets the wallet address of the oracle/backend node. This wallet address gets write access to update the merkle root.         |
| 4setMerkleRoot.js             | Sets up the merkle root for creda credit data. This merkle root is then updated daily by authorized nodes (oracle backends). |
| 5checkStatus.js               | Test call with a simulated score in order the ensure the validity and consistency between computed data and the merkle root  |

## Deployment order (contracts depending on others)
1. (Optionnal) CREDA ERC20 token (CreditCore).
1. (Mandatory) The **DataContract** relies on the CREDA ERC20 token (CreditCore) for fees payments. For chains where it is decided to set a fee to 0, the deployment of the CREDA token contract is not necessary. In this case, give null as CREDA contract parameter to other contracts.
1. (Mandatory) The **CreditNFT** contract, as it requires the CREDA token and the oracle contract to be both deployed. In theory, the presence of the ERC20 contract is **mandatory** as the cNFT contract spends tokens to mint/upgrade the cNFT. Though on chains like Celo, the cNFT contract has been modified for now to remove this requirement and make minting free.

## How to upgrade upgradeable contracts
This contract is an upgradeable contract. Through the upgrade method of openzeppelin, the contract can be upgraded. For details, please refer to
[Writing Upgradeable Contracts](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable)

## Contribution
Thank you for considering to help out with the source code! We welcome contributions from anyone on the internet, and are grateful for even the smallest of fixes!

If you'd like to contribute to creda-contracts, please fork, fix, commit and send a pull request for the maintainers to review and merge into the main code base.

## License

creda-contracts is an GPL v3.0-licensed open source project with its ongoing development made possible entirely by the support of the elastos team.

[![License: GPL v3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for details.