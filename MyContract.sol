pragma solidity 0.5.0;

contract BlindAuction {
    address owner;
    uint256 public maxAdmins;
    uint256 public adminIndex = 0;
    uint256 public memberCount = 0;
    //Listing[] propertyList;
    
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
        mapping (string => Property) properties;
        //Property[] property;
    }
    
    struct Property {
        string propertyOwner;
        string description;
        uint256 value;
    }
    
    struct Listing {
        uint256 listingId;
        uint256 reservePrice;
        bytes32 description;
        Status status;
        uint256[] bids;
    }
    
    mapping (address => Admin) public admins;   
    mapping (address => Member) public members;
    mapping (uint256 => Listing) public listings;
    mapping (address => uint256) public balances;
    
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
        memberCount += 1;
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
    
    function addListing(uint256 _listingId, uint256 _reservePrice, bytes32 _description) external onlyAdmin {
        //if(listings[_listingId].status = ForSale) {
          //  revert('Already listed');
        //}else{
        //    listings[_listingId].status = Status.ForSale;
       // }
        Listing storage _listingStruct = listings[_listingId];
        _listingStruct.listingId = _listingId;
        _listingStruct.reservePrice = _reservePrice;
        _listingStruct.description = _description;
        //propertyList.push(listings[_listingId]);
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
       _listingStruct.bids.push(_bidPrice);
   }
       
}