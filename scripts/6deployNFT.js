const {
    writeConfig
} = require('./utils/helper')
const { ethers: hEether } = require('hardhat');

const {
    readConfig
} = require('./utils/helper')


const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners();
    let deployer = accounts[0];

    console.log("address : ",deployer.address);

    let dataContractAddress = await readConfig("0", "DATA_CONTRACT_ADDRESS")
    // constructor(string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) {
    const creditNFTFactory = await ethers.getContractFactory("CreditNFT",deployer);

    creditNFTHandler = await creditNFTFactory.connect(deployer).deploy(
        dataContractAddress
    );

    console.log("data credit NFTHandler :",creditNFTHandler.address);    
    await writeConfig("0","0","NFT_HANDLER_ADDRESS",creditNFTHandler.address);

}

main();
