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

All scripts are under the scripts folder.

### 1deployUpgradeDataContract.js
This script deploys the DataContract contract to the chain.

### 2setFee.js
Set the cost of creda calls, the default cost is 0

### 3setNode.js
Set the address of the node

### 4setMerkleRoot.js
Set up merkle root for creda credit data

### 5checkStatus.js
Verify the validity and consistency of personal data via merkle root

## Deployment order (contracts depending on others)
This contract(DataContract) relies on Creditcore as a token for fee payment. If the fee is set to 0, it does not need to be called.

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