// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title UniVaultRegistry (All-in-one)
 * @notice Single contract that:
 *   1) Anchors DIDs (controller + DID doc URI + integrity hash)
 *   2) Issues credentials (stores doc hash + URI), supports bitmap revocation
 *   3) Verifies basic credential validity against a provided hash
 *   4) Logs verification attempts immutably without PII (audit trail)
 *
 * Roles:
 *  - DEFAULT_ADMIN_ROLE: system admin (can grant/revoke roles)
 *  - ISSUER_ROLE: approved universities that can issue/revoke credentials
 *  - VERIFIER_ROLE: (optional) accounts allowed to log verification events
 *
 * Notes:
 *  - Only content integrity data is on-chain (hash + URI); the document lives off-chain (e.g., IPFS)
 *  - Revocation is a per-issuer bitmap (gas-efficient at scale)
 */

import "@openzeppelin/contracts/access/AccessControl.sol";

contract UniVaultRegistry is AccessControl {
    // ─────────────────────────────────────────────────────────────────────────────
    // Roles
    // ─────────────────────────────────────────────────────────────────────────────
    bytes32 public constant ISSUER_ROLE   = keccak256("ISSUER_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    constructor(address admin) {
        address a = admin == address(0) ? msg.sender : admin;
        _grantRole(DEFAULT_ADMIN_ROLE, a);
        _grantRole(VERIFIER_ROLE, a); // grant verifier to admin; can grant more later
    }

    // ─────────────────────────────────────────────────────────────────────────────
    // DID Anchoring (Identity Registry)
    // ─────────────────────────────────────────────────────────────────────────────

    struct DIDAnchor {
        address controller;   // who can update this DID record
        string  didURI;       // pointer to DID Document (ipfs://CID or https://...)
        bytes32 docHash;      // optional integrity hash of DID Document (canonical bytes)
    }

    // subject (holder) address -> anchor
    mapping(address => DIDAnchor) private _didOf;

    event DIDAnchored(address indexed subject, address indexed controller, string didURI, bytes32 docHash);
    event DIDControllerChanged(address indexed subject, address indexed newController);
    event DIDURIUpdated(address indexed subject, string didURI, bytes32 docHash);

    /**
     * @notice Holder anchors their DID pointer & optional DID doc integrity hash.
     */
    function anchorMyDID(string calldata didURI, bytes32 docHash) external {
        _didOf[msg.sender] = DIDAnchor({controller: msg.sender, didURI: didURI, docHash: docHash});
        emit DIDAnchored(msg.sender, msg.sender, didURI, docHash);
    }

    /**
     * @notice Change controller for a subject's DID anchor (controller or admin-managed).
     */
    function setDIDController(address subject, address newController) external {
        DIDAnchor storage d = _didOf[subject];
        require(d.controller == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "not controller/admin");
        d.controller = newController;
        emit DIDControllerChanged(subject, newController);
    }

    /**
     * @notice Update DID document URI & integrity hash (controller or admin).
     */
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

    // ─────────────────────────────────────────────────────────────────────────────
    // Credentials + Bitmap Revocation
    // ─────────────────────────────────────────────────────────────────────────────

    struct Credential {
        // Integrity + linkage
        bytes32 docHash;          // keccak256 hash of the credential bytes (canonical)
        string  uri;              // IPFS CID or gateway URL

        // Parties
        address issuer;           // must have ISSUER_ROLE
        address subject;          // holder's address

        // Timestamps
        uint64  issuedAt;         // block timestamp
        uint64  expiresAt;        // 0 = no expiry

        // Revocation bitmap index (per-issuer)
        uint256 issuerSeqIndex;   // sequential index assigned on issuance
    }

    uint256 private _nextCredentialId = 1;
    mapping(uint256 => Credential) private _credentialOf;

    // Issuer -> next sequential index to assign (bit position source)
    mapping(address => uint256) private _issuerNextSeq;

    // issuer => wordIndex => 256-bit word where each bit indicates "revoked"
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

    /**
     * @notice Admin onboards an issuer (university).
     */
    function addIssuer(address university) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(ISSUER_ROLE, university);
        emit IssuerAdded(university);
    }

    /**
     * @notice Admin removes issuer permissions.
     */
    function removeIssuer(address university) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(ISSUER_ROLE, university);
        emit IssuerRemoved(university);
    }

    /**
     * @notice Record a new credential on-chain (hash + URI).
     */
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

    /**
     * @notice Revoke a credential previously issued by caller (bitmap flip).
     */
    function revokeCredential(uint256 credId) external onlyRole(ISSUER_ROLE) {
        Credential storage c = _credentialOf[credId];
        require(c.issuer != address(0), "not found");
        require(c.issuer == msg.sender, "not issuer");

        (uint256 wordIndex, uint256 bitMask) = _bitmapPos(c.issuerSeqIndex);
        _revocationBitmap[msg.sender][wordIndex] |= bitMask;

        emit CredentialRevoked(credId, msg.sender, c.issuerSeqIndex);
    }

    /**
     * @notice Check if credential is revoked by its issuer (bitmap lookup).
     */
    function isRevoked(uint256 credId) public view returns (bool) {
        Credential storage c = _credentialOf[credId];
        require(c.issuer != address(0), "not found");
        (uint256 wordIndex, uint256 bitMask) = _bitmapPos(c.issuerSeqIndex);
        return (_revocationBitmap[c.issuer][wordIndex] & bitMask) != 0;
    }

    /**
     * @notice Read credential metadata.
     */
    function getCredential(uint256 credId) external view returns (Credential memory) {
        Credential memory c = _credentialOf[credId];
        require(c.issuer != address(0), "not found");
        return c;
    }

    /**
     * @notice Verify basic validity of a credential against a provided document hash.
     * @dev Off-chain verifier should fetch `uri`, canonicalize bytes, keccak256, and pass that here.
     */
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

    // ─────────────────────────────────────────────────────────────────────────────
    // Verification / Access Logging (privacy-preserving)
    // ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Verifiers can emit an immutable log of a verification attempt without PII.
     * @param credId            Credential ID checked
     * @param presentationHash  Hash of the selective disclosure / ZK proof bytes
     * @param success           Outcome of off-chain checks (sig/schema/hash/status)
     * @param context           Optional tag (e.g., "age>=18", "employment") or ""
     */
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

    // ─────────────────────────────────────────────────────────────────────────────
    // Internals
    // ─────────────────────────────────────────────────────────────────────────────

    function _bitmapPos(uint256 seqIndex) internal pure returns (uint256 wordIndex, uint256 bitMask) {
        wordIndex = seqIndex >> 8;        // divide by 256
        uint256 bitPos = seqIndex & 255;  // modulo 256
        bitMask = (uint256(1) << bitPos);
    }
}
