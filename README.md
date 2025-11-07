# UniVault | University Credential Management System

**Group 31**

This is a lightweight and gas effecient smart contract system to issue and verify university credentials on Ethereum. Storing only cryptographic proofs on chain makes it privacy protected verification and keeps sensitive data off-chain.

---

## Description of the project

Following key features are provided in Univault:

- **Off-chain Storage**: Files kept off the blockchain, with only verification codes stored on-chain
- **Role-Based Access**: OpenZeppelin's AccessControl to manage admin, creater, and student roles
- **Gas-Optimized Revocation**: Using bitmap-based revocation system for low cost updates
- **DID Support**: Students can self-manage 
- **Verifiable Integrity**: keccak256 hashing for proof system
- **Extensible Design**: Keeping the structure modular for future developments

---

## Architecture

### On-Chain Components
- Document hash
- storage location link
- Creater and student addresses
- Expiration timestamp
- Per creater revocation bitmap

### Off-Chain Components
- Credential documents
- Stored externally

### Roles
- **Admin**: Onboards universities as creaters
- **Creater**: Creates and revokes credentials
- **Student**: Self-manages DID string for linking credentials

---

## Quick Start (Remix IDE)

The fastest way to demo UniVault without any local installation.

### Setup
1. Open Remix IDE at https://remix.ethereum.org
2. Create a new file: `UniVault.sol`
3. Paste the contract code
4. Set Solidity compiler version to 0.8.18 or higher
5. Select environment: JavaScript VM (Remix default)

### How to use or deploy

```solidity
// Constructor parameter:
admin: 0x0000000000000000000000000000000000000000
// (Passing zero address makes deployer the admin)
```

Click Deploy.

### Basic Workflow

#### Add a Creater (Admin Only)
```javascript
// to switch to admin account
addNewCreater("0x5B38Da6a701c568545dCfcB03FcB875f56beddC4")
```

#### Student Sets DID
```javascript
// to switch to student account
setUserDID("did:key:zStudentExample123")

// to verify DID was set
getUserDID("0xStudentAddress")
```

#### Create a Credential (Creater Only)
```javascript
// to switch to creater account
createCredential(
  "0xStudentAddress",
  "docHash",
  "uri",
  0  // 0 = never expires
)
```

Note the `credId` (e.g., `1`) from the transaction logs or `CredentialCreated` event.

#### Verify a Credential
```javascript
verifyCredential(
  1,  // credId
  "providedDocHash"
)
// If valid it returns: (true, "OK")
```

#### Revoke a Credential (Creater Only)
```javascript
// to switch to creater account
revokeExistingCredential(1)

// to check revocation status
isCredRevoked(1)  // Returns: true

// to verification now fails
verifyCredential(1, "0x...")  // returns (false, "REVOKED")
```

## Smart Contract Interface

### Core Functions

#### Admin Functions
```solidity
function addNewCreater(address university) external
function removeCreater(address university) external
```

#### Creater Functions
```solidity
function createCredential(
    address subject,
    bytes32 docHash,
    string calldata uri,
    uint64 expiresAt
) external returns (uint256 credId)

function revokeExistingCredential(uint256 credId) external
```

#### Student Functions
```solidity
function setUserDID(string calldata did) external
```

#### View Functions
```solidity
function verifyCredential(uint256 credId, bytes32 providedDocHash) 
    external view returns (bool isValid, string memory reason)

function getUserCredential(uint256 credId) 
    external view returns (Credential memory)

function getUserDID(address student) 
    external view returns (string memory)

function isCredRevoked(uint256 credId) 
    external view returns (bool)
```

---

## Security Considerations

- **Access Control**: Authorized creaters can create or revoke credentials
- **Hash Verification**: to prove content integrity
- **No Private Data On-Chain**: Sensitive information stored off-chain only
- **Immutable Records**: Issued credentials cannot be modified, only revoked
- **Gas Efficiency**: Bitmap revocation minimizes costs
