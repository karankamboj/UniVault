// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract UniVault is AccessControl {
    using Strings for uint256;
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin == address(0) ? msg.sender : admin);
    }

    mapping(address => string) private _didOf;

    function setMyDID(string calldata did) external {
        _didOf[msg.sender] = did;
        emit DIDSet(msg.sender, did);
    }

    function getDID(address student) external view returns (string memory) {
        return _didOf[student];
    }

    event DIDSet(address indexed student, string did);

    struct Credential {
        bytes32 docHash;
        string uri;
        address issuer;
        address subject;
        uint64 issuedAt;
        uint64 expiresAt;
        uint256 issuerSeqIndex;
    }

    uint256 private _nextCredentialId = 1;
    mapping(uint256 => Credential) private _credentialOf;
    mapping(address => uint256) private _issuerNextSeq;
    mapping(address => mapping(uint256 => uint256)) private _revocationBitmap;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    function addIssuer(address university) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(ISSUER_ROLE, university);
        emit IssuerAdded(university);
    }

    function removeIssuer(address university) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(ISSUER_ROLE, university);
        emit IssuerRemoved(university);
    }

    event IssuerAdded(address indexed university);
    event IssuerRemoved(address indexed university);

    function issueCredential(address subject, bytes32 docHash, string calldata uri, uint64 expiresAt)
        external
        onlyRole(ISSUER_ROLE)
        returns (uint256 credId)
    {
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

    function revokeCredential(uint256 credId) external onlyRole(ISSUER_ROLE) {
        Credential storage c = _credentialOf[credId];
        require(c.issuer != address(0), "not found");
        require(c.issuer == msg.sender, "not issuer");

        (uint256 wordIndex, uint256 bitMask) = _bitmapPos(c.issuerSeqIndex);
        _revocationBitmap[msg.sender][wordIndex] |= bitMask;

        emit CredentialRevoked(credId, msg.sender, c.issuerSeqIndex);
    }

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

    function _bitmapPos(uint256 seqIndex) internal pure returns (uint256 wordIndex, uint256 bitMask) {
        wordIndex = seqIndex >> 8;
        uint256 bitPos = seqIndex & 255;
        bitMask = (uint256(1) << bitPos);
    }

    event CredentialIssued(
        uint256 indexed credId,
        address indexed issuer,
        address indexed subject,
        bytes32 docHash,
        string uri,
        uint256 issuerSeqIndex,
        uint64 expiresAt
    );

    event CredentialRevoked(
        uint256 indexed credId,
        address indexed issuer,
        uint256 issuerSeqIndex
    );
}