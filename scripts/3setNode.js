const {
    NAME721,SYMBOL721,BASEURI,
    readConfig, sleep, attachStakeTicket
} = require('./utils/helper')
const { ethers: hEether,upgrades } = require('hardhat');


const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let autherAddress = "0x9D16512DD5b6C96E9E2196d30ff44F31Ca2d6077";

    let accounts = await hEether.getSigners();
    let deployer = accounts[0];


    let dataContractAddress = await readConfig("0", "DATA_CONTRACT_ADDRESS")

    const dataContractFactory = await ethers.getContractFactory('DataContract',deployer)
    let dataContract  = await dataContractFactory.connect(deployer).attach(dataContractAddress);

    let txObj = await dataContract.setAuthorizedtNode(autherAddress);
    let txRep = await txObj.wait();
    console.log(txRep);



}

main();
