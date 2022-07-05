//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./AutherController.sol";
import "./lib/ManagerString.sol";
import "./lib/MerkleProof.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/math/SafeERC20.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
contract DataContract is AutherController {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    IERC20  CredaCore;
    mapping(address => address) public addressBinds;
    mapping(address => address[]) bindLists;
    bytes32 public merkleRoot;
    struct CreditInfo {
       uint256 credit;
       bytes did; //did
       uint256 timestamp;
       bool didStatus;
    }
    mapping(address => CreditInfo)  _creditInfo;
    mapping(address => address[])  creditSource;
    address public receiverAddress;
    uint256 public credaFee = 10 ** 17;
    event bindEvent(uint indexed method,address  _main,address  _second,bytes _value);
    event unbindEvent(uint indexed method,address  _main,address  _second);
    event MerkleRootChanged(bytes32 merkleRoot);
    event updateCredaEvent(address indexed _sender,address indexed _user,uint256 credit);
    function initialize(address credaCore_, address receiverAddress_)public initializer{
		__Ownable_init();
        CredaCore=IERC20(credaCore_);
        receiverAddress = receiverAddress_;
	}
    
    function setCredaFee(uint256 _fee) onlyOwner external {
         credaFee = _fee;
    }

    function getAddressBySource(address _source) external view returns(address[] memory){
        return creditSource[_source];
    }
    function getBindLists(address _address) external view returns(address[] memory){
        return bindLists[_address];
    }
    function getDidByAddress(address  _address) external view returns (bytes memory) {
         return !_creditInfo[_address].didStatus? createDidByAddress(_address):_creditInfo[_address].did;
         
    }
    function getCreditInfo(address _address) external view   returns(CreditInfo memory){
        return _creditInfo[_address];
    }
    function creditOf(address _address) external view   returns (uint256) {
        return _creditInfo[_address].credit;
    }


    function creditDetail(address _address) external view   returns (uint16[16] memory) {
        uint256 credit = _creditInfo[_address].credit;
        return [bytesToUint(getByteByIndex(credit,0)),bytesToUint(getByteByIndex(credit,1)),bytesToUint(getByteByIndex(credit,2)),bytesToUint(getByteByIndex(credit,3)),bytesToUint(getByteByIndex(credit,4)),bytesToUint(getByteByIndex(credit,5)),bytesToUint(getByteByIndex(credit,6)),bytesToUint(getByteByIndex(credit,7)),bytesToUint(getByteByIndex(credit,8)),bytesToUint(getByteByIndex(credit,9)),bytesToUint(getByteByIndex(credit,10)),bytesToUint(getByteByIndex(credit,11)),bytesToUint(getByteByIndex(credit,12)),bytesToUint(getByteByIndex(credit,13)),bytesToUint(getByteByIndex(credit,14)),bytesToUint(getByteByIndex(credit,15))];    
    }
    function getRoot() external view returns(bytes32) {
       return merkleRoot;
   }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyAuthorizedNodes {
        merkleRoot = _merkleRoot;
        emit MerkleRootChanged(_merkleRoot);
    }
       
    function updateCredit(address _address,uint256 credit,bytes32[] memory merkleProof) public {
        require(checkStatus(_address,credit,merkleProof),"Merkle verify error");
        if(credaFee > 0){
           CredaCore.safeTransferFrom(msg.sender,receiverAddress,credaFee);
        }
         CreditInfo memory creditInfo = _creditInfo[_address];
         creditInfo.credit = credit;
         if(!creditInfo.didStatus){
            creditInfo.did = createDidByAddress(_address);
            creditInfo.didStatus = true;
        }
        creditInfo.timestamp = block.timestamp;
        _creditInfo[_address] = creditInfo;
        emit updateCredaEvent(msg.sender,_address,credit);
    }
   function checkStatus(address _address,uint256 credit,bytes32[] memory merkleProof) external  view returns(bool flag){
        bytes32 leaf = hash(_address,credit);
        flag = MerkleProof.verify(merkleProof, merkleRoot, leaf);
   }
   function hash(address _address,uint256 score) public pure returns(bytes32) {
       return keccak256(abi.encodePacked(_address,score));
   }
   function encodePacked(address _address,uint256 score) public pure returns(bytes memory) {
       return abi.encodePacked(_address,score);
   }

    function isBindOf(address  mainAddress,address secondAddress) external view returns (uint256) {
        address info =  addressBinds[secondAddress];
        if(info == address(0x0)) {
            return 0;
        }else if(info == mainAddress) {
            return 1;
        }
         return 2;
    }

    function createDidByAddress(address _address) public pure returns(bytes memory) {
        bytes memory newbytes = new bytes(32);
        bytes32 keccak = keccak256(abi.encodePacked(ManagerString.toAsciiString(_address)));
       for(uint i= 0;i < 32;i++){
           newbytes[i] = keccak[i];
       }
        return newbytes;
    }
    
    //绑定did
     function bindAddress(address mainAddress) public  virtual {
        require(mainAddress != address(0x0) ,"address error " );
        address  secondAddress = msg.sender;
        require(addressBinds[secondAddress] == address(0x0)," has bind" );
        bytes memory _value = _creditInfo[mainAddress].did;
        if(!_creditInfo[mainAddress].didStatus){
             _value = createDidByAddress(mainAddress);
            _creditInfo[mainAddress].did = _value;
            _creditInfo[mainAddress].didStatus = true;
            _creditInfo[secondAddress].did = _value;
            addressBinds[secondAddress] = mainAddress;
            bindLists[mainAddress].push(secondAddress);
        }else{
             _creditInfo[secondAddress].did = _value;
            _creditInfo[secondAddress].didStatus = true;
            addressBinds[secondAddress] = mainAddress;
            bindLists[mainAddress].push(secondAddress);
        }
        emit bindEvent(0,mainAddress,secondAddress,_value);
    }


    
    function bytesToUint(bytes memory byte_) public pure returns (uint16){
        uint16 number;
        for(uint i= 0; i<byte_.length; i++){
            number = number + uint16(uint8(byte_[i])*(2**(8*(byte_.length-(i+1)))));
        }
        return  number;
    }

    function getByteByIndex(uint256 credit,uint8 index) public pure returns (bytes memory  b) {
        bytes32 sc=  bytes32(credit);
        bytes memory sb=new bytes(2);
        uint from = index * 2;
        for(uint i=0;i<2;i++){
            sb[i]=sc[from+i];
        }
        return sb;
    }
}