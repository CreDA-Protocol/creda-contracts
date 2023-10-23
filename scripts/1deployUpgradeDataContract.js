const {
    writeConfig
} = require('./utils/helper')
const { ethers: hEether,upgrades } = require('hardhat');


const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners();
    let deployer = accounts[0];

    // constructor(string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) {
    const dataContractFactory = await ethers.getContractFactory("DataContract",deployer);

    const dataContractContract = await upgrades.deployProxy(
        dataContractFactory,
        [
        ],
        {
            initializer:  "initialize",
            unsafeAllowLinkedLibraries: true,
        }
    );

    console.log("data contract address :",dataContractContract.address);
    
    await writeConfig("0","0","DATA_CONTRACT_ADDRESS",dataContractContract.address);


}

main();
