const {
    NAME721,SYMBOL721,BASEURI,
    readConfig, sleep, attachStakeTicket
} = require('./utils/helper')
const { ethers: hEether,upgrades } = require('hardhat');


const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let autherAddress = "";

    let accounts = await hEether.getSigners();
    let deployer = accounts[0];


    let dataContractAddress = await readConfig("0", "DATA_CONTRACT_ADDRESS")

    const dataContractFactory = await ethers.getContractFactory('DataContract',deployer)
    let dataContract  = await dataContractFactory.connect(deployer).attach(dataContractAddress);


    let merkleRoot = "0x61910961c1d8a7a7acf9a6c454d403efdb7214a7207ca594b71eba23aec11cd2";
    let txObj = await dataContract.setMerkleRoot(merkleRoot);
    let txRep = await txObj.wait();
    console.log(txRep);



}

main();
