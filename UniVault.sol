// The identifier for the licence
pragma solidity ^0.8.18;

// This is the interface for defining UniVault Aplicatiom
interface UniVault {

    // creater is issuer
    
    // This will set the DID for the student
    function setUserDID(string calldata did) external;

    /// This is the getter for the student to get their DID
    function getUserDID(address student) external view returns (string memory);

    // We have to define the strucuture of the credential system
    struct Credential {
        bytes32 docHash;        // It will be hash of the file in the URI
        string  uri;            // the Url to access the file
        address creater;         // who is the creater of the credential
        address subject;        // this is the address of the student
        uint64  createdAt;       // what is the the time of the create
        uint64  expiresAt;      // this defines when the credential will expire, 0 means no expiry
        uint256 createrSeqIndex; // the position of the creater in the index
    }

    // this will return the credential if the id of the cred is given
    function getUserCredential(uint256 credId) external view returns (Credential memory);

    // tasks for the admin
    // admin can add a new user, the creater. The address of the account has to be passed
    function addNewCreater(address university) external;

    // the admin can also remove the creater.
    function removeCreater(address university) external;

    // this function will create a credential based on the given input
    function createCredential(
        address subject,
        bytes32 docHash,
        string calldata uri,
        uint64 expiresAt
    ) external returns (uint256 credId);

    /// This function will revoke the credential. Only creater can do this. No other user should have the access
    function revokeExistingCredential(uint256 credId) external;

    /// This method is to check the revoke status of the credential. Is it revoked or not
    function isCredRevoked(uint256 credId) external view returns (bool);

    // This method is used to validate if the credential is expired/revoked?
    function verifyCredential(
        uint256 credId,
        bytes32 providedDocHash
    ) external view returns (bool isValid, string memory reason);

    // Events are used for logging
    // This will be used in the method when DID is set
    event DIDIsSet(address indexed student, string did);
    event CreaterAdded(address indexed university); // used when creater is added
    event CreaterRemoved(address indexed university); // used when creater is removed
    
    event CredentialCreated( // this event will emit when the credential is created
        uint256 indexed credId, // id of the cred
        address indexed creater, // who created the credential
        address indexed subject, // address of the account
        bytes32 docHash, /// hash of the file
        string uri, // uri to access file
        uint256 createrSeqIndex, // index of the creater
        uint64  expiresAt // expiry time
    );

    event CredentialRevoked( // this is to log when the credential is revoked or not
        uint256 indexed credId,
        address indexed creater,
        uint256 createrSeqIndex
    );
}
