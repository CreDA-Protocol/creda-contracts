const {
    NAME721,SYMBOL721,BASEURI,
    readConfig, sleep, attachStakeTicket
} = require('./utils/helper')
const { ethers: hEether,upgrades } = require('hardhat');


const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let autherAddress = "0xEe48f42CCaE13b011ce5796fE4646a5A3B786Ca8";

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
