pragma solidity >=0.5.0 < 0.6.0;

import "./DappToken.sol";

contract BlindAuction is DappToken {
    address owner;
    uint256 public maxAdmins;
    uint256 public adminIndex = 0;
    uint256 public memberCount = 0;
    
    enum Status {
        ForSale,
        ReserveNotMet,
        Sold
    }
    
    struct Admin {
        bool isAuthorized;
        uint256 id;
    }
    
    struct Member {
        string fullName;
        string email;
        bool isWhitelisted;
        mapping (uint256 => Property) properties;
        //Property[] property;
    }
    
    struct Property {
        string description;
        uint256 value;
        Status status;
    }
    
    struct Listing {
        uint256 listingId;
        Property property;
        uint256 reservePrice;
        bytes32 description;
        uint256[] bids;
    }
    
    mapping (address => Admin) public admins;   
    mapping (address => Member) public members;
    mapping (uint256 => Listing) listings;
    mapping (address => uint256) public balances;
    mapping (uint256 => uint256[]) public bids;
    
    event NewAuction(uint256 indexed _listingId, uint256 indexed _reservePrice, bytes32 _description, address _propertyOwner);
    
    modifier onlyOwner() {
        require(owner == msg.sender, 'Only owner can make this call');
        _;
    }
    
    modifier onlyAdmin() {
        require(admins[msg.sender].isAuthorized = true, 'Only admins can make this call');
        _;
    }
    
    modifier onlyWhitelistedMember(address _addr) {
        require(members[_addr].isWhitelisted = true, 'Not an eligible member');
        _;
    }
    
    modifier onlyBlacklistedMember(address _addr) {
        require(members[_addr].isWhitelisted = false, 'Not an eligible member');
        _;
    }
    
    // Constructor
    constructor() public {
        maxAdmins = 2;
        _addAdmin(msg.sender);
    }
    
    //Functions
    function addAdmin(address _addr) external onlyOwner {
        _addAdmin(_addr);
    }
    
    function _addAdmin(address _addr) private {
        if(admins[_addr].isAuthorized = true) {
            revert('Already and admin');
        }else{
            admins[_addr].isAuthorized = true;
        }
        Admin memory _adminStruct;
        admins[_addr] = _adminStruct;
        adminIndex += 1;
    }
    
    function removeAdmin(address _addr) external onlyOwner {
        _removeAdmin(_addr);
    }
    
    function _removeAdmin(address _addr) private {
        require(admins[_addr].isAuthorized = true, 'Not an admin');
        require(adminIndex > 1, 'Cannot operate without an admin');
        delete admins[_addr];
        adminIndex -= 1;
    }
    
    function addMember(string calldata _fullName, string calldata _email) external onlyAdmin {
        Member memory _memberStruct;
        _memberStruct.fullName = _fullName;
        _memberStruct.email = _email;
        _memberStruct.isWhitelisted = true;
        memberCount++;
    }
    
    function whiteListMember(address _addr) external onlyAdmin onlyBlacklistedMember(_addr){
       Member memory _memberStruct;
       members[_addr] = _memberStruct;
       _memberStruct.isWhitelisted = true;
    }
    
    function blackListMember(address _addr) external onlyAdmin onlyWhitelistedMember(_addr){
       Member storage memberStruct = members[_addr];
       memberStruct.isWhitelisted = false;
    }
    
    function openBidding(uint256 _listingId, uint256 _reservePrice, bytes32 _description, address _propertyOwner) external onlyAdmin {
        Listing storage _listingStruct = listings[_listingId];
        _listingStruct.listingId = _listingId;
        _listingStruct.reservePrice = _reservePrice;
        _listingStruct.description = _description;
        members[_propertyOwner].properties[_listingId].status = Status.ForSale;
        Property memory property; 
        members[_propertyOwner].properties[_listingId] = property;
        emit NewAuction(_listingId, _reservePrice, _description, _propertyOwner);
    }
    
   // function getListings() external view returns(uint256, uint256, bytes32){
    //    Listing storage listing = listings[][];
   //     listingId = 
   //     return (listingId, reservePrice, description);
   // }
   
    function bid(uint256 _listingId, uint256 _bidPrice, address _addr) external onlyWhitelistedMember(_addr){
       require(balances[_addr] >= _bidPrice, 'Insufficient funds');
       Listing storage _listingStruct = listings[_listingId];
       _listingStruct.listingId = _listingId;
       super.approve(address(this), _bidPrice);
       bids[_listingId].push(_bidPrice);
    }

   // function closeBidding(uint256 _listingId, address _property)
    
    
    
}
    
    
    
