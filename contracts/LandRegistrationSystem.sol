//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LandRegistrationSystem {
    struct Land {
        uint landId;
        string city;
        string district;
        string state;
        address owner;
        uint marketValue;
        uint size;
        string landDocument;
        bool verified;
        bool forSell;
    }

    struct User {
        uint userId;
        address walletAddress;
        string emailAddress;
        string firstName;
        string lastName;
        string contact;
        string residentialAddress;
        string ghanaCard;
        uint landSold;
        bool verified;
    }

    struct LandInspector {
        uint inspectorId;
        address walletAddress;
        string district;
        string city;
        uint verifiedUser;
        uint verifiedLand;
    }

    Land[] private land;
    User[] private user;
    LandInspector[] private landInspector;

    address owner;
    mapping (uint => address) public users;
    mapping (uint => address) public landInspectors;
    mapping (uint => address) public lands; // use propertyNumber as primary key

    event LandSold(address indexed _seller, address indexed _buyer, uint _value);
    event AddLand(address recipient, uint taskId);
    event AddUser(address recipient, uint taskId);
    event AddlandInspector(address recipient, uint taskId);

    uint public unlockTime;

    // constructor(uint _unlockTime) payable {
    //     require(
    //         block.timestamp < _unlockTime,
    //         "Unlock time should be in the future"
    //     );

    //     unlockTime = _unlockTime;
    //     owner = payable(msg.sender);
    // }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyLandOwner(uint landId) {
        require(lands[landId] == msg.sender, "You are not the land owner.");
        _;
    }

    // modifier onlyLandInspector() {
    //     require(landInspectors[msg.sender].walletAddress == msg.sender, "You are not a land inspector.");
    //     _;
    // }

    function createUser(string memory _emailAddress, string memory _firstName, string memory _lastName, string memory _contact, string memory _residentialAddress, string memory _ghanaCard) public {
        require(bytes(_emailAddress).length > 0, "Email address is required");
        require(bytes(_firstName).length > 0, "First name is required");
        require(bytes(_lastName).length > 0, "Last name is required");
        require(bytes(_contact).length > 0, "Contact is required");
        require(bytes(_residentialAddress).length > 0, "Residential address is required");
        require(bytes(_ghanaCard).length > 0, "Ghana card is required");
        uint userId = user.length;
        user.push(User(userId, msg.sender, _emailAddress, _firstName, _lastName, _contact, _residentialAddress, _ghanaCard,0, false));
        users[userId] = msg.sender;
        emit AddUser(msg.sender, userId);
    }

    // onlyLandInspector

    function verifyUser(uint inspectorId, uint userId, bool isverified) external {
        user[userId].verified = isverified;
        // require(users[userId].walletAddress == userAddress, "User not found");
        landInspector[inspectorId].verifiedUser++;
    }

    function createLand(string memory _city, string memory _district, string memory _state, string memory _propertyNumber, uint _marketValue, uint _size, string memory _landDocument) public {
        require(bytes(_city).length > 0, "City is required");
        require(bytes(_district).length > 0, "District is required");
        require(bytes(_state).length > 0, "State is required");
        require(bytes(_propertyNumber).length > 0, "Property number is required");
        require(_marketValue > 0, "Market value is required and must be greater than zero");
        require(_size > 0, "Size is required and must be greater than zero");
        require(bytes(_landDocument).length > 0, "Land document is required");
        uint landId = land.length;
        land.push( Land(landId, _city, _district, _state, msg.sender, _marketValue, _size, _landDocument, false, false));
        lands[landId] = msg.sender;
        emit AddLand(msg.sender, landId);
        // add propertyNumber to user's list of owned lands
    }


    function getLandDetails(uint landId) public view returns (string memory, string memory, string memory, uint, uint, bool) {
        require(land[landId].verified == true, "Land is not yet verified");
        return (land[landId].city, land[landId].district, land[landId].state, land[landId].marketValue, land[landId].size, land[landId].forSell);
    }

    function createLandInspector(string memory _district, string memory _city) public {
        require(bytes(_district).length > 0, "District is required");
        require(bytes(_city).length > 0, "City is required");
        uint landInspectorId = landInspector.length;
        landInspector.push( LandInspector(landInspectorId, msg.sender, _district, _city, 0, 0));
        landInspectors[landInspectorId] = msg.sender;
        emit AddlandInspector(msg.sender, landInspectorId);
    }

// onlyLandInspector
    function verifyLand(uint landId) public  {
        // require(lands[landId] == msg.sender, "You are not the land owner.");
        land[landId].verified = true;
        // landInspector[msg.sender].verifiedLand++;
    }

    function setLandForSale(uint landId) public onlyLandOwner(landId) {
        land[landId].forSell = true;
    }

    function cancelSale(uint landId) public onlyLandOwner(landId) {
        land[landId].forSell = false;
    }

    function unverifiedOwnerLands()  external view returns (Land[] memory) {
        Land[] memory temporary = new Land[](land.length);
        uint counter = 0;
        for(uint i=0; i<land.length; i++) {
            if(lands[i] == msg.sender && land[i].verified == false) {
                temporary[counter] = land[i];
                counter++;
            }
        }

        Land[] memory result = new Land[](counter);
        for(uint i=0; i<counter; i++) {
            result[i] = temporary[i];
        }
        return result;
    }
    
    function getOwnerLands()  external view returns (Land[] memory) {
        Land[] memory temporary = new Land[](land.length);
        uint counter = 0;
        for(uint i=0; i<land.length; i++) {
            if(lands[i] == msg.sender && land[i].verified == true) {
                temporary[counter] = land[i];
                counter++;
            }
        }

        Land[] memory result = new Land[](counter);
        for(uint i=0; i<counter; i++) {
            result[i] = temporary[i];
        }
        return result;
    }

    function countOwnerLands()  external view returns (uint) {
        Land[] memory temporary = new Land[](land.length);
        uint counter = 0;
        for(uint i=0; i<land.length; i++) {
            if(lands[i] == msg.sender && land[i].verified == true) {
                temporary[counter] = land[i];
                counter++;
            }
        }
        return counter;
    }

    function getNonVerifiedLands()  external view returns (Land[] memory) {
        Land[] memory temporary = new Land[](land.length);
        uint counter = 0;
        for(uint i=0; i<land.length; i++) {
            if(land[i].verified == false) {
                temporary[counter] = land[i];
                counter++;
            }
        }

        Land[] memory result = new Land[](counter);
        for(uint i=0; i<counter; i++) {
            result[i] = temporary[i];
        }
        return result;
    }

    function searchLands(string memory _keyword) external view returns (Land[] memory) {
        Land[] memory temporary = new Land[](land.length);
        uint counter = 0;
        for(uint i=0; i<land.length; i++) {
            if(keccak256(bytes(land[i].city)) == keccak256(bytes(_keyword)) || keccak256(bytes(land[i].district)) == keccak256(bytes(_keyword))) {
                temporary[counter] = land[i];
                counter++;
            }
        }

        Land[] memory result = new Land[](counter);
        for(uint i=0; i<counter; i++) {
            result[i] = temporary[i];
        }
        return result;
    }

    
    function getNonVerifiedUsers()  external view returns (User[] memory) {
        User[] memory temporary = new User[](user.length);
        uint counter = 0;
        for(uint i=0; i<user.length; i++) {
            if(user[i].verified == false) {
                temporary[counter] = user[i];
                counter++;
            }
        }

        User[] memory result = new User[](counter);
        for(uint i=0; i<counter; i++) {
            result[i] = temporary[i];
        }
        return result;
    }

    function getLands()  external view returns (Land[] memory) {
        Land[] memory temporary = new Land[](land.length);
        uint counter = 0;
        for(uint i=0; i<land.length; i++) {
                temporary[counter] = land[i];
                counter++;
        }

        Land[] memory result = new Land[](counter);
        for(uint i=0; i<counter; i++) {
            result[i] = temporary[i];
        }
        return result;
    }

    function buyLand(uint  landId) public payable {
        require(land[landId].verified == true, "Land is not yet verified");
        require(land[landId].forSell == true, "Land is not for sale");
        require(msg.value >= land[landId].marketValue, "Insufficient funds");

        address payable seller = payable(land[landId].owner);
        seller.transfer(msg.value);
        land[landId].owner = msg.sender;
        land[landId].forSell = false;

        emit LandSold(seller, msg.sender, msg.value);
    }

}