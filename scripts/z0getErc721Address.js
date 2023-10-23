const {
    readConfig, sleep, attachStakeTicket
} = require('./utils/helper')

const { ethers: hEether,upgrades } = require('hardhat');


const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners();
    let owner = accounts[0];

    const stakestick = await ethers.getContractFactory('StakeTicket',owner);
    const instanceV1 = await stakestick.attach(stakeSticketAddress);

    let version = await instanceV1.version();
    console.log("instanceV1", instanceV1.address, "version", version);

    


}

main();
