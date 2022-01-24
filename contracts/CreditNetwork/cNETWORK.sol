// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../owner/AdminRole.sol";



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

contract cNETWORK is AdminRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public creda;
    address public creditOracle;
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
        address token_,
        address creditOracle_,
        address creditNFT_     
    ) {
        creda = token_;
        creditOracle = creditOracle_;
        creditNFT = creditNFT_;
    }

    function ActiveStatus(address account) public view returns (bool) {
        if(ICreditNFT(creditNFT).getOwnerNFTNo(account) == 0){
            return true;
        }
        return activeStatus[ICreditNFT(creditNFT).getOwnerNFTNo(account)];
    }

    function Active(address account) public returns (bool) {
        require(ICreditNFT(creditNFT).getOwnerNFTNo(account) > 0, "No Credit NFT Exist");
        require(activeStatus[ICreditNFT(creditNFT).getOwnerNFTNo(account)] == false, "Credit NFT Actived");
        activeStatus[ICreditNFT(creditNFT).getOwnerNFTNo(account)] = true;
        netInfo[account].csSetting = 500;
        return true;
    }

    function SetCS(uint256 _creditScore) external returns(bool){
        require( _creditScore <= 1000, "exceed the limit");
        netInfo[msg.sender].csSetting = _creditScore;
        return true;
    }

    function Relation(address accountA_, address accountB_) internal returns(bool){
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

    function LayerStatus(uint256 _pid, address _account) public view returns(uint256){
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

    function SetLayerStatus(uint256 _pid, address _account,uint256 _amount) external onlyAdmin{
        require(_pid < 5,"exceed the limit");
        if(_pid == 0){
            netInfo[_account].layer1amount = _amount;
        }
        else if(_pid == 1){
            netInfo[_account].layer2amount = _amount;
        }
        else if(_pid == 2){
            netInfo[_account].layer3amount = _amount;
        }
        else if(_pid == 3){
            netInfo[_account].layer4amount = _amount;
        }
        else {
            netInfo[_account].layer5amount = _amount;
        }
    } 

    function SetCreDA(address token_) external onlyAdmin {
        creda = token_;
    }

    function SetCreditNFT(address token_) external onlyAdmin {
        creditNFT = token_;
    }

    function SetCreditOracle(address creditOracle_) external onlyAdmin {
        creditOracle = creditOracle_;
    }
  

    function EfficientNetwork() public view returns(uint256){
        uint256 EffNet = 0;
        for(uint256 i; i< netInfo[msg.sender].cnetwork.length; i++)
        {
            if(ICredaOracle(creditOracle).totalCredit(netInfo[msg.sender].cnetwork[i]) >= netInfo[msg.sender].csSetting)
            {
                EffNet += 1;
            }
        }
        return EffNet;
    }



    function addNetwork(address account, address[] memory _group) external onlyAdmin{
        for(uint256 i = 0; i< _group.length; i++){
            require(_group[i] != address(0),"Wrong Data");
            require(_group[i] != account,"Wrong Data");
            require(creditRelation[account][_group[i]] = false,"Address Exist");
            netInfo[account].cnetwork.push(_group[i]);
            netInfo[account].layer1amount += 1;
            creditRelation[account][_group[i]] = true;
        }
    }  

    function addNetwork(address[] memory _group) public {
        for(uint256 i = 0; i< _group.length; i++){
            require(_group[i] != address(0),"Wrong Data");
            require(_group[i] != msg.sender,"Wrong Data");
            require(creditRelation[msg.sender][_group[i]] = false,"Address Exist");
            netInfo[msg.sender].cnetwork.push(_group[i]);
            netInfo[msg.sender].layer1amount += 1;
            creditRelation[msg.sender][_group[i]] = true;
        }
    } 

}
