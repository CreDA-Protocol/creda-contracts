# CreDA Protocol

#CreDA API Description


Request address
---------------
https://contracts-elamain.creda.app/api/public/home/token/generate


Request method
---------------

GET



Request parameters
------------------

|Header Parameter|Data Type|Required|Description|
| ------ | ------ | ------ | ------ |
|access_token|string|yes||
|Query Parameter|Data Type|Required|Description|
| ------ | ------ | ------ | ------ |
|address|string|yes|address informatin|

Return parameters
-----------------

|Parameter Name|Data Type|Description|
| ------ | ------ | ------ |
| code | integer | Return code 200 is success |
| message | string | "success" or reason for failure |
| data | Object | Data Object |


Data Object
-----------

| Parameter Name | Data Type | Description |
| ------ | ------ | ------ |
| score | Array | socre object |
| timestamp | string | score timestamp |

Score array item description
----------------------------

| Attribute Name | Data Type | Description |
| ------ | ------ | ------ |
| itemName | string | name of score item |
| value | string | score value |


Example Return Value
--------------------

     {
        "code": 200,
        "message": "SUCCESS",
        "data": {
        "score":[
                {
                    "itemName":"assets",
                    "value":100
                },
                {
                    "itemName":"activities",
                    "value":100
                },
                {
                    "itemName":"risk",
                    "value":100
                },
                {
                    "itemName":"credit",
                    "value":100
                }
            ]
        }
    }


# Dependencies

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

# copy .env.sample and add pricate key
cp .env.sample .env

# deploy to celo network
yarn scripts scripts/1deployUpgradeDataContract.js --network celo

# set Fee defalut is 0
yarn scripts scripts/2setFee.js --network celo

```

# Contribution
Thank you for considering to help out with the source code! We welcome contributions from anyone on the internet, and are grateful for even the smallest of fixes!

If you'd like to contribute to creda-contracts, please fork, fix, commit and send a pull request for the maintainers to review and merge into the main code base. 


## License  

creda-contracts is an GPL v3.0-licensed open source project with its ongoing development made possible entirely by the support of the elastos team. 

[![License: GPL v3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for details.

