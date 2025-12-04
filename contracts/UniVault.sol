pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract UniVault is AccessControl {
    bytes32 public constant ISSUER_ROLE   = keccak256("ISSUER_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    constructor(address admin) {
        address a = admin == address(0) ? msg.sender : admin;
        _grantRole(DEFAULT_ADMIN_ROLE, a);
        _grantRole(VERIFIER_ROLE, a); 
    }

    struct DIDAnchor {
        address controller;   // can update this DID record
        string  didURI;       // like ipfs://CID
        bytes32 docHash;      // integrity hash of document
    }

    // This is subject's address
    mapping(address => DIDAnchor) private _didOf;

    event DIDAnchored(address indexed subject, address indexed controller, string didURI, bytes32 docHash);
    event DIDControllerChanged(address indexed subject, address indexed newController);
    event DIDURIUpdated(address indexed subject, string didURI, bytes32 docHash);


    function anchorMyDID(string calldata didURI, bytes32 docHash) external {
        _didOf[msg.sender] = DIDAnchor({controller: msg.sender, didURI: didURI, docHash: docHash});
        emit DIDAnchored(msg.sender, msg.sender, didURI, docHash);
    }

     //this is admin managed
    function setDIDController(address subject, address newController) external {
        DIDAnchor storage d = _didOf[subject];
        require(d.controller == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "not controller/admin");
        d.controller = newController;
        emit DIDControllerChanged(subject, newController);
    }

    function setDIDURI(address subject, string calldata didURI, bytes32 docHash) external {
        DIDAnchor storage d = _didOf[subject];
        require(d.controller == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "not controller/admin");
        d.didURI = didURI;
        d.docHash = docHash;
        emit DIDURIUpdated(subject, didURI, docHash);
    }

    function getDID(address subject) external view returns (DIDAnchor memory) {
        return _didOf[subject];
    }

    struct Credential {
        bytes32 docHash;          // keccak256 hash
        string  uri;              // IPFS CID
        address issuer;           // must have ISSUER_ROLE
        address subject;          // holder's address
        uint64  issuedAt;      
        uint64  expiresAt;        // no expiry = 0
        // this is per issuer revocation bitmap index, assigned sequentially
        uint256 issuerSeqIndex;  
    }

    uint256 private _nextCredentialId = 1;
    mapping(uint256 => Credential) private _credentialOf;

    // next index to assign sequentially
    mapping(address => uint256) private _issuerNextSeq;

    // each bit in 256 bit word is "revoked"
    mapping(address => mapping(uint256 => uint256)) private _revocationBitmap;

    event CredentialIssued(
        uint256 indexed credId,
        address indexed issuer,
        address indexed subject,
        bytes32 docHash,
        string uri,
        uint256 issuerSeqIndex,
        uint64  expiresAt
    );
    event CredentialRevoked(
        uint256 indexed credId,
        address indexed issuer,
        uint256 issuerSeqIndex
    );
    event IssuerAdded(address indexed university);
    event IssuerRemoved(address indexed university);


    function addIssuer(address university) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(ISSUER_ROLE, university);
        emit IssuerAdded(university);
    }

    function removeIssuer(address university) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(ISSUER_ROLE, university);
        emit IssuerRemoved(university);
    }

     //recording cred on chain
    function issueCredential(
        address subject,
        bytes32 docHash,
        string calldata uri,
        uint64  expiresAt
    ) external onlyRole(ISSUER_ROLE) returns (uint256 credId) {
        require(subject != address(0), "subject=0");
        require(docHash != bytes32(0), "hash=0");

        uint256 seq = _issuerNextSeq[msg.sender]++;
        credId = _nextCredentialId++;

        _credentialOf[credId] = Credential({
            docHash: docHash,
            uri: uri,
            issuer: msg.sender,
            subject: subject,
            issuedAt: uint64(block.timestamp),
            expiresAt: expiresAt,
            issuerSeqIndex: seq
        });

        emit CredentialIssued(credId, msg.sender, subject, docHash, uri, seq, expiresAt);
    }


     //bitmap lookup to revoke when already issued
    function revokeCredential(uint256 credId) external onlyRole(ISSUER_ROLE) {
        Credential storage c = _credentialOf[credId];
        require(c.issuer != address(0), "not found");
        require(c.issuer == msg.sender, "not issuer");

        (uint256 wordIndex, uint256 bitMask) = _bitmapPos(c.issuerSeqIndex);
        _revocationBitmap[msg.sender][wordIndex] |= bitMask;

        emit CredentialRevoked(credId, msg.sender, c.issuerSeqIndex);
    }

    
     //bitmap lookup to check if revoked by issuer
    function isRevoked(uint256 credId) public view returns (bool) {
        Credential storage c = _credentialOf[credId];
        require(c.issuer != address(0), "not found");
        (uint256 wordIndex, uint256 bitMask) = _bitmapPos(c.issuerSeqIndex);
        return (_revocationBitmap[c.issuer][wordIndex] & bitMask) != 0;
    }

    
    function getCredential(uint256 credId) external view returns (Credential memory) {
        Credential memory c = _credentialOf[credId];
        require(c.issuer != address(0), "not found");
        return c;
    }

    function verifyCredential(uint256 credId, bytes32 providedDocHash)
        external
        view
        returns (bool isValid, string memory reason)
    {
        Credential storage c = _credentialOf[credId];
        if (c.issuer == address(0)) {
            return (false, "NOT_FOUND");
        }
        if (isRevoked(credId)) {
            return (false, "REVOKED");
        }
        if (c.expiresAt != 0 && block.timestamp > c.expiresAt) {
            return (false, "EXPIRED");
        }
        if (c.docHash != providedDocHash) {
            return (false, "HASH_MISMATCH");
        }
        return (true, "OK");
    }

    event VerificationLogged(
        uint256 indexed credId,
        address indexed verifier,
        bytes32 presentationHash,
        bool success,
        string context
    );

    function logVerification(
        uint256 credId,
        bytes32 presentationHash,
        bool success,
        string calldata context
    ) external onlyRole(VERIFIER_ROLE) {
        Credential storage c = _credentialOf[credId];
        require(c.issuer != address(0), "not found");
        emit VerificationLogged(credId, msg.sender, presentationHash, success, context);
    }

    function _bitmapPos(uint256 seqIndex) internal pure returns (uint256 wordIndex, uint256 bitMask) {
        wordIndex = seqIndex >> 8;        // divide by 256
        uint256 bitPos = seqIndex & 255;  // % 256
        bitMask = (uint256(1) << bitPos);
    }
}
