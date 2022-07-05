// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



interface ICreditNFT {
        function getOwnerNFTLevel(address account)
        external view
        returns (uint8);
        function getOwnerNFTNo(address account)
        external view
        returns (uint256);
}

interface ICredaOracle {

    function totalCredit(address acount)
        external
        view
        returns (uint256);
}

contract cNETWORK is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public dataContract;
    address public creditNFT;
    mapping(uint256 => bool) public activeStatus;
 
    mapping(address => mapping(address => bool)) public creditRelation;

    struct NetInfo {
        uint256 index; 
        uint8  nftLevel;
        uint256 csSetting;
        address[] cnetwork;
        uint256 layer1amount;
        uint256 layer2amount;
        uint256 layer3amount;
        uint256 layer4amount;
        uint256 layer5amount;
    }
    mapping(address => NetInfo) public netInfo;

   
    constructor(
        address dataContract_,
        address creditNFT_     
    ) {
        dataContract = dataContract_;
        creditNFT = creditNFT_;
    }

    function ActiveStatus(address account) external view returns (bool) {
        if(ICreditNFT(creditNFT).getOwnerNFTNo(account) == 0){
            return true;
        }
        return activeStatus[ICreditNFT(creditNFT).getOwnerNFTNo(account)];
    }

    function Active(address account) public returns (bool) {
        require(ICreditNFT(creditNFT).getOwnerNFTNo(account) > 0, "No Credit NFT Exist");
        require(!activeStatus[ICreditNFT(creditNFT).getOwnerNFTNo(account)], "Credit NFT Actived");
        activeStatus[ICreditNFT(creditNFT).getOwnerNFTNo(account)] = true;
        netInfo[account].csSetting = 500;
        return true;
    }

    function SetCS(uint256 _creditScore) external returns(bool){
        require( _creditScore <= 1000, "exceed the limit");
        netInfo[msg.sender].csSetting = _creditScore;
        return true;
    }

    function Relation(address accountA_, address accountB_) external view returns(bool){
        return (creditRelation[accountA_][accountB_] || creditRelation[accountB_][accountA_]);
    }

    function setWhiteList(address account) external {
        require(account != address(0),"Zero Address");
        require(account != msg.sender,"Cannot set Self");
        creditRelation[msg.sender][account] = true;
    }

    function setBlackList(address account) external {
        require(account != address(0),"Zero Address");
        require(account != msg.sender,"Cannot set Self");
        creditRelation[msg.sender][account] = false;
    }

    function LayerStatus(uint256 _pid, address _account) external view returns(uint256){
        require(_pid < 5,"exceed the limit");
        if(_pid == 0){
            return netInfo[_account].layer1amount;
        }
        else if(_pid == 1){
            return netInfo[_account].layer2amount;
        }
        else if(_pid == 2){
            return netInfo[_account].layer3amount;
        }
        else if(_pid == 3){
            return netInfo[_account].layer4amount;
        }
        else {
            return netInfo[_account].layer5amount;
        }
    }


    function EfficientNetwork() external view returns(uint256 EffNet){
        EffNet = 0;
        for(uint256 i = 0; i< netInfo[msg.sender].cnetwork.length; i++)
        {
            if(ICredaOracle(dataContract).totalCredit(netInfo[msg.sender].cnetwork[i]) >= netInfo[msg.sender].csSetting)
            {
                EffNet += 1;
            }
        }
        return EffNet;
    }


    function addNetwork(address[] memory _group) external {
        for(uint256 i = 0; i< _group.length; i++){
            require(_group[i] != address(0),"Wrong Data");
            require(_group[i] != msg.sender,"Wrong Data");
            require(!creditRelation[msg.sender][_group[i]],"Address Exist");
            netInfo[msg.sender].cnetwork.push(_group[i]);
            netInfo[msg.sender].layer1amount += 1;
            creditRelation[msg.sender][_group[i]] = true;
        }
    } 

}
