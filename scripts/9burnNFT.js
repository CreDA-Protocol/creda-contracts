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


    let nftHandleAddress = await readConfig("0", "NFT_HANDLER_ADDRESS")

    const creditNFTFactory = await ethers.getContractFactory("CreditNFT",deployer);

    let creditNFTContract  = await creditNFTFactory.connect(deployer).attach(nftHandleAddress);

    let txObj = await creditNFTContract.burnNFT(10001);
    let txRep = await txObj.wait();
    console.log(txRep);



}

main();
