//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../owner/AdminRole.sol";


contract CreditNFT is ERC721Enumerable, AdminRole {

    uint256 public nftNumber = 10000;
    mapping(uint256 => CardItem) public nftsDict;
    mapping(address => uint8) public whiteList;    // 可以拥有超过一个NFT的地址
    mapping(address => uint256) public ownerNFT;


    constructor(address[] memory _whiteList) ERC721("Credit NFT", "cNFT") {
            for (uint256 i=0;i < _whiteList.length; i++){
            whiteList[_whiteList[i]] = 1;
        }
    }

    struct CardItem {
        bool isActive;           // 是否为默认
        uint8 exists;       // 1存在、0不存在
        uint256 level;       // 等级
        uint256 amount; //CREDA token amount
    }


    modifier checkExists(uint256 _nftNo){
        require (nftsDict[_nftNo].exists > 0, "Credit NFT: no exists");
        _;
    }

    modifier checkOwner(address _owner, uint256 _nftNo){
        require (ownerOf(_nftNo) == _owner, "Credit NFT: it is not yours");
        _;
    }

    function transferFrom(address from, address to, uint256 tokenId)
        public virtual override
    {
        if (whiteList[to] == 0) {
            require (balanceOf(to) == 0, "Credit NFT Exist");
        }
        super.transferFrom(from, to, tokenId);
        ownerNFT[from] = 0;
        ownerNFT[to] = tokenId;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId)
        public virtual override
    {
        if (whiteList[to] == 0) {
            require (balanceOf(to) == 0, "Credit NFT Exist");
        }
        super.safeTransferFrom(from, to, tokenId);
        ownerNFT[from] = 0;
        ownerNFT[to] = tokenId;
    }

    function _safeMint(address to, uint256 tokenId)
        internal virtual override
    {
        if (whiteList[to] == 0) {
            require (balanceOf(to) == 0, "Credit NFT Exist");
        }
        super._safeMint(to, tokenId);
    }

    function isExists(uint256 _nftNo)
        public view
        returns (uint8)
    {
        return nftsDict[_nftNo].exists;
    }

    function getOwnerNFTInfo(address _owner)
        public view
        returns (uint256 nftNo, uint256 level)
    {
        nftNo = ownerNFT[_owner];
        if (nftNo > 0){
            level = nftsDict[nftNo].level;
        } else {
            level = 0;
        }
    }

    function getOwnerNFTNo(address _owner)
        public view
        returns (uint256)
    {
        return ownerNFT[_owner];
    }

    function getNFTsLevelNum(uint256 _level)
        public view
        returns (uint256 lvNum)
    {
        lvNum = nftsLevelNum[_level];
    }

    function getNFTLevel(uint256 _nftNo)
        public view checkExists(_nftNo)
        returns (uint256)
    {
        return nftsDict[_nftNo].level;
    }

    function getNFTList(uint256[] memory _nftNoList)
        public onlyAdmin view
        returns (CardItem[] memory infoList)
    {
        infoList = new CardItem[](_nftNoList.length);
        for (uint256 i=0; i< _nftNoList.length; i++){
            infoList[i] = nftsDict[_nftNoList[i]];
        }
    }

    function mintNFT(address _to)
        public onlyAdmin
        returns (uint256 nftNo)
    {
        require(ICREDA()unlockedOf)
        // 获取NFT的序号
        nftNumber++;
        nftNo = nftNumber;
        // 创建carditem
        _safeMint(_to, nftNo);
        ownerNFT[_to] = nftNo;
        nftsDict[nftNo] = CardItem({
            exists: 1,
            isActive: false,
            level: 1,
            amount: 1
        });

    }

    // NFT升级
    function updateNFTLevel(address _owner, uint256 _nftNo, uint256 _newLevel)
        public onlyAdmin checkExists(_nftNo) checkOwner(_owner, _nftNo)
    {
        nftsDict[_nftNo].level = _newLevel;
    }

    function updateNFTAmount(address _owner, uint256 _nftNo, uint256 _newAmount)
        public onlyAdmin checkExists(_nftNo) checkOwner(_owner, _nftNo)
    {
        nftsDict[_nftNo].amount = _newAmount;
    }


    function setWhiteList(address _addr, uint8 _open)
        public onlyAdmin
    {
        // _open > 0 为开，0为关。
        whiteList[_addr] = _open;
    }

    function setNFTNumber(uint256 _number)
        public onlyAdmin
    {
        nftNumber = _number;
    }

}

}
