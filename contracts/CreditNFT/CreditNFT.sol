// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../owner/AdminRole.sol";
import "../interfaces/ICredaOracle.sol";

interface ICREDA {
    function unlockedOf(address account) external view returns (uint256);
    function lockedOf(address account) external view returns (uint256);
}


contract CreditNFT is ERC721, AdminRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public immutable creda;
    address public immutable creditOracle;
    uint256 public totalTokenAmount;
    uint256 public totalSupply;
    uint256 public NUM = 10000;
    uint256 public constant mintamount = 10**18;
    mapping(uint256 => CreditStatus) public nftsDict;
    mapping(address => bool) public whiteList;    // 可以拥有超过一个NFT的地址
    mapping(address => uint256) public ownerNFT;
    

    constructor(address creda_, address creditOracle_) ERC721("Credit NFT", "cNFT") {
            creda = creda_;
            creditOracle = creditOracle_;
        }
    struct CreditStatus {
        bool isActive;           // 是否为默认
        bool exists;       // 1存在、0不存在
        uint8 level;       // 等级
        uint256 amount;     //CREDA token amount
        bytes32 did;
        uint256 index;
    }
    modifier checkOwner(address _owner, uint256 _nftNo){
        require (ownerOf(_nftNo) == _owner, "Credit NFT: it is not yours");
        _;
    }
    modifier checkExists(uint256 _nftNo){
        require (nftsDict[_nftNo].exists, "Credit NFT: no exists");
        _;
    }



    function transferFrom(address from, address to, uint256 nftNo)
        public virtual override
    {
        if (!whiteList[to]) {
            require (balanceOf(to) == 0, "Credit NFT Exist");
        }
        super.transferFrom(from, to, nftNo);
        ownerNFT[from] = 0;
        ownerNFT[to] = nftNo;
    }

    function safeTransferFrom(address from, address to, uint256 nftNo)
        public virtual override
    {
        if (!whiteList[to]) {
            require (balanceOf(to) == 0, "Credit NFT Exist");
        }
        super.safeTransferFrom(from, to, nftNo);
        ownerNFT[from] = 0;
        ownerNFT[to] = nftNo;
    }

    function _safeMint(address to, uint256 nftNo)
        internal virtual override
    {
        if (!whiteList[to]) {
            require (balanceOf(to) == 0, "Credit NFT Exist");
        }
        super._safeMint(to, nftNo);
    }

    function isExists(uint256 _nftNo)
        public view
        returns (bool)
    {
        return nftsDict[_nftNo].exists;
    }

    function getOwnerNFTLevel(address _owner)
        public view
        returns (uint8)
    {
        uint256 nftNo = ownerNFT[_owner];
        if (nftNo > 0){
            return nftsDict[nftNo].level;
        } else {
            return 0;
        }
    }

    function getOwnerNFTNo(address _owner)
        public view
        returns (uint256)
    {
        return ownerNFT[_owner];
    }


    function getNFTLevel(uint256 _nftNo)
        public view checkExists(_nftNo)
        returns (uint8)
    {
        return nftsDict[_nftNo].level;
    }

    function getNFTList(uint256[] memory _nftNoList)
        public onlyAdmin view
        returns (CreditStatus[] memory infoList)
    {
        infoList = new CreditStatus[](_nftNoList.length);
        for (uint256 i=0; i< _nftNoList.length; i++){
            infoList[i] = nftsDict[_nftNoList[i]];
        }
    }


    function mintNFT()
        public
        returns (uint256 nftNo)
    {
        require(ICREDA(creda).unlockedOf(msg.sender) >= mintamount,"Balance is not enough.");
        NUM++;
        nftNo = NUM;
        _safeMint(msg.sender, nftNo);
        ownerNFT[msg.sender] = nftNo;
        nftsDict[nftNo] = CreditStatus({
            exists: true,
            isActive: true,
            level: 1,
            amount: mintamount,
            did: ICredaOracle(creditOracle).getDidByAddress(msg.sender),
            index: 0
        });
        IERC20(creda).safeTransferFrom(msg.sender, address(this), mintamount);
        totalTokenAmount += mintamount;
        totalSupply += 1;
    }

    function burnNFT(uint256 _nftNo)
        public
        checkOwner(msg.sender, _nftNo)
        returns (bool)
    {   
        IERC20(creda).safeTransfer(msg.sender, nftsDict[_nftNo].amount);
        totalTokenAmount -= nftsDict[_nftNo].amount;
        nftsDict[_nftNo].amount = 0;
        _burn(_nftNo);
        totalSupply -= 1;
        return true;
    }


    function updateNFTAmount(uint256 _nftNo, uint256 _newAmount)
        public  checkExists(_nftNo) checkOwner(msg.sender, _nftNo)
    {
        require(ICREDA(creda).unlockedOf(msg.sender) > _newAmount,"Balance is not enough."); 
        nftsDict[_nftNo].amount += _newAmount;
        IERC20(creda).safeTransferFrom(msg.sender, address(this), _newAmount);
        totalTokenAmount += _newAmount;
        checkNFTLevel(_nftNo);
    }

    function checkNFTLevel(uint256 _nftNo)
        public checkExists(_nftNo) returns(bool)
    {
        if(nftsDict[_nftNo].level == _checkNFTLevel(_nftNo)){
            return true;
        }
        nftsDict[_nftNo].level = _checkNFTLevel(_nftNo);
        return true;
    }


    function _checkNFTLevel(uint256 _nftNo)
        public view checkExists(_nftNo) returns(uint8)
    {
        require(totalSupply > 0, "Nont cNFT Exist");
        if( totalSupply >= 1000000 && nftsDict[_nftNo].amount >= 100 * 100 * totalTokenAmount/totalSupply){
        return 5;
        } else if( totalSupply >= 100000 && nftsDict[_nftNo].amount >= 50 * 50 * totalTokenAmount/totalSupply){
        return 4;
        } else if( totalSupply >= 10000 && nftsDict[_nftNo].amount >= 20 * 20 * totalTokenAmount/totalSupply){
        return 3;
        } else if( totalSupply >= 1000 && nftsDict[_nftNo].amount >= 5 * 5 * totalTokenAmount/totalSupply){
        return 2;
        } else {
        return 1;
        }
    }


    function setWhiteList(address _addr, bool _open)
        public onlyAdmin
    {
        whiteList[_addr] = _open;
    }


    function launchMigrate(address token, address to, uint256 amount) external onlyAdmin {
        IERC20(token).safeTransfer(to, amount);
    }
}
