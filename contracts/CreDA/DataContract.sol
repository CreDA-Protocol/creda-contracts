//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./AutherController.sol";
import "./lib/ManagerString.sol";
import "./lib/MerkleProof.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
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
    IERC20  credaToken;
    mapping(address => address) public addressBinds;
    mapping(address => address[]) bindLists;
    bytes32 public merkleRoot;
    struct CreditInfo {
       uint256 credit;
       bytes did; //did
       uint256 timestamp;
       uint didStatus;
    }
    mapping(address => CreditInfo)  _creditInfo;
    mapping(address => address[])  creditSource;
    address public receiverAddress;
    uint256 public credaFee;
  //  uint256 public creditTimeDif;
    event bindEvent(uint indexed method,address  _main,address  _second,bytes _value);
    event unbindEvent(uint indexed method,address  _main,address  _second);
    event MerkleRootChanged(bytes32 merkleRoot);
    event updateCredaEvent(address indexed _sender,address indexed _user,uint256 credit);
    function initialize()public initializer{
		__Ownable_init();
       // credaToken=IERC20(0x6812891dD6Ab4e2ebDde659a57EB8dA5F25B0Dd3);
        credaToken=IERC20(0xc136E6B376a9946B156db1ED3A34b08AFdAeD76d);
        receiverAddress = 0xC36f3435Fe583e9489E28ae54E77e44E94d193b1;
       // credaFee=100000000000000000; //0.1
       // creditTimeDif = 86400; //24小时
	}
    
    function changeCredaToken(address _creda) onlyOwner external {
       credaToken=IERC20(_creda);
    }
    function setCredaFee(uint256 _fee) onlyOwner external {
         credaFee = _fee;
    }
    function setReceiverAddress(address _address)  onlyOwner external {
        receiverAddress = _address;
    }
    // function setCreditTimeDif(uint256 _time)  onlyOwner external {
    //     creditTimeDif = _time;
    // }
    
    function getAddressBySource(address _source) public view returns(address[] memory){
        return creditSource[_source];
    }
    function getBindLists(address _address) public view returns(address[] memory){
        return bindLists[_address];
    }
    function getDidByAddress(address  _address) public view returns (bytes memory) {
         return _creditInfo[_address].didStatus == 0? createDidByAddress(_address):_creditInfo[_address].did;
         
    }
    function getCreditInfo(address _address) public view   returns(CreditInfo memory){
        return _creditInfo[_address];
    }
    function creditOf(address _address) public view   returns (uint256) {
        return _creditInfo[_address].credit;
    }


    function creditDetail(address _address) public view   returns (uint16[16] memory) {
        uint256 credit = _creditInfo[_address].credit;
        return [bytesToUint(getByteByIndex(credit,0)),bytesToUint(getByteByIndex(credit,1)),bytesToUint(getByteByIndex(credit,2)),bytesToUint(getByteByIndex(credit,3)),bytesToUint(getByteByIndex(credit,4)),bytesToUint(getByteByIndex(credit,5)),bytesToUint(getByteByIndex(credit,6)),bytesToUint(getByteByIndex(credit,7)),bytesToUint(getByteByIndex(credit,8)),bytesToUint(getByteByIndex(credit,9)),bytesToUint(getByteByIndex(credit,10)),bytesToUint(getByteByIndex(credit,11)),bytesToUint(getByteByIndex(credit,12)),bytesToUint(getByteByIndex(credit,13)),bytesToUint(getByteByIndex(credit,14)),bytesToUint(getByteByIndex(credit,15))];    
    }
    function getRoot() public view returns(bytes32) {
       return merkleRoot;
   }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
        emit MerkleRootChanged(_merkleRoot);
    }
       
    function updateCredit(address _address,uint256 credit,bytes32[] memory merkleProof) public {
        require(checkStatus(_address,credit,merkleProof),"Merkle verify error");
        if(credaFee>0){
           credaToken.transferFrom(msg.sender,receiverAddress,credaFee);
        }
         CreditInfo memory creditInfo = _creditInfo[_address];
        _creditInfo[_address].credit = credit;
         if(creditInfo.didStatus == 0 ){
            creditInfo.did = createDidByAddress(_address);
            creditInfo.didStatus=1;
        }
        creditInfo.timestamp = block.timestamp;
        _creditInfo[_address] = creditInfo;
        emit updateCredaEvent(msg.sender,_address,credit);
    }
   function checkStatus(address _address,uint256 credit,bytes32[] memory merkleProof) public  view returns(bool flag){
        bytes32 leaf = hash(_address,credit);
        flag = MerkleProof.verify(merkleProof, merkleRoot, leaf);
   }
   function hash(address _address,uint256 score) public pure returns(bytes32) {
       return keccak256(abi.encodePacked(_address,score));
   }
   function encodePacked(address _address,uint256 score) public pure returns(bytes memory) {
       return abi.encodePacked(_address,score);
   }

    function isBindOf(address  mainAddress,address secondAddress) public view returns (uint256) {
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
        if(_creditInfo[mainAddress].didStatus==0){
             _value = createDidByAddress(mainAddress);
            _creditInfo[mainAddress].did = _value;
            _creditInfo[mainAddress].didStatus =1;
            _creditInfo[secondAddress].did = _value;
            addressBinds[secondAddress] = mainAddress;
            bindLists[mainAddress].push(secondAddress);
        }else{
             _creditInfo[secondAddress].did = _value;
            _creditInfo[secondAddress].didStatus =1;
            addressBinds[secondAddress] = mainAddress;
            bindLists[mainAddress].push(secondAddress);
        }
        emit bindEvent(0,mainAddress,secondAddress,_value);
    }
    function unBindAddress(address mainAddress) public   returns (bool) {
        require(mainAddress != address(0x0) && addressBinds[msg.sender] == mainAddress,"user unbind main address " );
         _creditInfo[msg.sender].did = "";
         _creditInfo[msg.sender].didStatus=0;
        delete addressBinds[msg.sender];
        emit unbindEvent(0,mainAddress,msg.sender);
         return true;
    }
    
    function batchUpdateAllCredit(address[] calldata _address,uint256[] calldata _credits) external  onlyAuthorizedNodes  {
        uint size = _address.length;
        require(size == _credits.length ,"length not equals");
         for(uint i=0;i<size;i++){
            _creditInfo[_address[i]].credit = _credits[i];
        }
    }
    function bytesToUint(bytes memory b) public pure returns (uint16){
        uint16 number;
        for(uint i= 0; i<b.length; i++){
            number = number + uint16(uint8(b[i])*(2**(8*(b.length-(i+1)))));
        }
        return  number;
    }
     //0x00000000000000000000000000000000000000000000000003e801f400320064
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