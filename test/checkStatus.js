/* External Imports */
// const { ethers, network,} = require('hardhat')
const { ethers, getChainId, upgrades, network } = require('hardhat')
const { utils } = require('ethers')
const chai = require('chai')
const { solidity } = require('ethereum-waffle')
const { expect, assert } = chai


chai.use(solidity)

describe(`main process`, () => {


  let dataContract;
  before(`deploy contact and setting `, async () => {



    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await ethers.getSigners();
    let deployer = accounts[0];

    // constructor(string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) {
    let dataContractFactory = await ethers.getContractFactory("DataContract",deployer);

    dataContract = await upgrades.deployProxy(
        dataContractFactory,
        [
        ],
        {
            initializer:  "initialize",
            unsafeAllowLinkedLibraries: true,
        }
    );

    console.log("data contract address :",dataContract.address);




  })


  it('main process checkStatus', async function () {

    let txObj = await dataContract.setCredaFee(0);
    let txRep = await txObj.wait();
    console.log(txRep.status);


    // let merkleRoot = "0xad1aa5d95b0fb90f10a7e65d0cc24e3d2e4ef3d52ef7ece98bf66da0f1f8bcfc";
    // let proof = [ "0xf8c02c49f4161410371cc2e2e5b335b91df239799f14882cce2c48987038ecc2","0x2ef492e3d85c23709b32e3b93969c51cf2321d901407265b85e703ffdff05076"]
    // let address = "0x3770219B0F2ED1986E46FaE53b5D1A70d5a32eAb"
    // let score = 800;
    // let leaf = "196dc3eb84a4901859c41729815bed7b34ff0c8fa3dc9663ed4f0bc5d479a091"


    let merkleRoot = "0x61910961c1d8a7a7acf9a6c454d403efdb7214a7207ca594b71eba23aec11cd2";
    let proof = ["0xb9ec0cd6d5fa0487f0a3297622b18055166e804d26d858a455979bae10ae75ba","0x9199015052f64b7e409ad9ca64d0a8e5c41ecc99e61f52cdf526a1a0f7975bfe"]
    let address = "0x8c49CAfC4542D9EA9107D4E48412ACEd2A68aA77"
    let score = "0x0032003200320032000000000000000000000000000000000000000000000000";
    let bufScore = Buffer.from(score);
    let leaf = "0x6c175eae9fc392828d79fbd0c0925e46c7630973c18f0d76fbe87dfa27810643";

    // function checkStatus(
    //     address _address,
    //     uint256 credit,
    //     bytes32[] memory merkleProof
    // ) public view returns (bool flag) {
    //     bytes32 leaf = hash(_address, credit);
    //     flag = MerkleProof.verify(merkleProof, merkleRoot, leaf);
    // }
    
    txObj= await dataContract.setMerkleRoot(merkleRoot);
    txRep = await txObj.wait();
    console.log(txRep.status);


    let result = await dataContract.checkStatus(address,score,proof);
    console.log(result);



  })

})
