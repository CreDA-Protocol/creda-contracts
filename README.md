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

## CreDA core contracts

| Contract     | Description                                                                                                                                                                      |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CredaCore    | CreDA **ERC20 token**. Deployed only on Arbitrum and ESC so far.                                                                                                                 |
| DataContract | The **Oracle** contract that deals with user accountsand credit scores.                                                                                                          |
| CreditNFT    | **Credit NFT** contract, into which users can mint/burn/upgrade/present their cNFT. The cNFT holds various information such as the credit score, NFT level, addresses list, etc. |

## Other related contracts

| Contract                            | Description                                                                                                                                                                                                                                                                                                                     |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| InitialMint, PersonalDataMinePool** | Those contracts were inherited from other projects and modified for creda. While they are not part of the core creda offer, they are used to let users claim their initial CREDA tokens and manage locked vs unlocked states, etc. Different chains user different version os those contracts (TODO: explain which one and why) |

### ERC20 token contract

| Chain    | Contract Address                           |
| -------- | ------------------------------------------ |
| ESC      | 0xc136E6B376a9946B156db1ED3A34b08AFdAeD76d |
| Arbitrum | 0xc136E6B376a9946B156db1ED3A34b08AFdAeD76d |
| Ropsten  | 0x6812891dD6Ab4e2ebDde659a57EB8dA5F25B0Dd3 |

### Credit NFT contract

| Chain       | Contract Address                           | Block explorer source code   |
| ----------- | ------------------------------------------ | ---------------------------- |
| Celo        | 0xDe19103a6Ef95312FF1bA093a9c78904D947A419 |                              |
| ESC         | 0x0E0e0fCb700c3CfEe1AeEa5c1d7A21dd90d1ce7E | Not verified / Not available |
| ESC TestNet | 0xd4563C741DE9C13F1Fdc31467AC6eAc451e10f57 |                              |
| Arbitrum    | 0x7308a054F7ADb93C286529aDc954976377eB0cF0 | Not verified / Not available |
| Ropsten     | 0x67EBeB38Ce79E0A3B723bA42393910504db28758 |                              |

### Data contract

| Chain       | Contract Address                           | Notes                  |
| ----------- | ------------------------------------------ | ---------------------- |
| Celo        | 0x878063db2d3d54e4F18e7bC448FA56A0e111C054 |                        |
| ESC         | 0xF8389a26E7ec713D15E7Fe9376B06CB63dE27624 | UNSURE - TEST ON GOING |
| Arbitrum    | 0x45def2f1eb5fb5235e9a4848fe1972ba9fc2f700 | UNSURE - TEST ON GOING |
| ESC TestNet | 0x36aFfC79ABBd2F8Aaf32800A1333c524aF3bCE79 |                        |

## Different behaviours between chains (2023.11.16)

- ESC and arbitrum have a CREDA token. Users can stake / use DeFi features such as banking. They have cNFT contracts, which according to our source code requires the data contract (oracle) in the constructor. Though we don't seem to be able to find those data contracts on ESC and arbitrum.
  - Note: after contract creation input decryption on ESC, it appears 0xF8389a26E7ec713D15E7Fe9376B06CB63dE27624 could be a "oracle" contract on ESC (second constructor parameter after the creda token address) - upgrade proxy address. Is this the "data contract" as we have it in latest source code?
  - On arbitrum, the oracle address passed to the cNFT constructor is 0x45def2f1eb5fb5235e9a4848fe1972ba9fc2f700
  - Note 2023.11.17: those addresses are actually related to "InitialMint"/"APIConsumer" contracts for which we don't have source code. They are not related to data contract. It's also probably uneasy/not doable to preserve the existing cNFT contract but change its creditOracle address to become a data contract.
- The cNFT contract of some chains like Celo, which originally requires to access the ERC20 token to pay fees while minting cNFTs, has been modified in order to remove the dependency on the ERC20 token when no ERC20 token is available.

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
| 5checkStatus.js               | Test call with a simulated score in order the ensure the validity and consistency between computed data and the merkle root. |
| 6deployNFT.js                 | This script deploys the CredaNFT contract to the chain.                                                                      |
| 7mintNFT.js                   | This script mint the NFT contract to the chain.                                                                              |
| 8updateNFTAmount.js           | This script update the NFT amount.                                                                                           |
| 9burnNFT.js                   | This script burn the NFT by nft ID.                                                                                          |

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