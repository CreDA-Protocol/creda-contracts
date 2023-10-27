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
    let proof = ["0xb9ec0cd6d5fa0487f0a3297622b18055166e804d26d858a455979bae10ae75ba","0x9199015052f64b7e409ad9ca64d0a8e5c41ecc99e61f52cdf526a1a0f7975bfe"]
    let address = "0x8c49CAfC4542D9EA9107D4E48412ACEd2A68aA77"
    let score = "0x0032003200320032000000000000000000000000000000000000000000000000";
    let bufScore = Buffer.from(score);
    let leaf = "0x6c175eae9fc392828d79fbd0c0925e46c7630973c18f0d76fbe87dfa27810643";

    let result = await dataContract.checkStatus(address,score,proof);
    console.log(result);



}

main();
