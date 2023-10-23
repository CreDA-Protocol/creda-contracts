
const { ethers, getChainId} = require('hardhat')
const {writeConfig } = require('./utils/helper')

const main = async () => {


    let chainID = await getChainId();
    //let chainID = 0;
    let accounts = await ethers.getSigners()
    let deployer = accounts[0];
    console.log("chainID is: " + chainID + " address: " + deployer.address);

    let name = "creda";
    let symbol = "CRD";

    const credaCoreFactory = await ethers.getContractFactory("CredaCore",deployer);
    const credaContract = await credaCoreFactory.deploy(
        name,symbol
    )

    await writeConfig("0","0","CREDA_ADDRESS",credaContract.address);

    console.log("cread address : ",credaContract.address);
    console.log("name", await credaContract.name(), "\nsymbol", await credaContract.symbol());
   
}



main();
