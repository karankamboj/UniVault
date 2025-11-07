# UniVault | University Credential Management System

**Group 31**

---

## Description of the project

This is a lightweight and gas effecient smart contract system to issue and verify university credentials on Ethereum. Storing only cryptographic proofs on chain makes it privacy protected verification and keeps sensitive data off-chain.


The idea of UniVault aims to change the credential management system for the universitiies and colleges by using latest coding technologies making a secure, and centralized system. The system should be very effecient for which will allow to save educational data. These days, students like us have to dead with many challenges during the need to fetch academic records becaause the process is very time taking, manual and consumes a lot of money. Also, the old  systems are easily to get risk because of hackers. We will solve these problems by providing students a very secure system where they can access their acadcemic data by themself whenever they want without any human or manual interaction, saving large amount of time and money.

Generally, when a user requests for the records like transcrips from the universities, there will be middlemans who are employees of the universtiy. But, with UniVault, there will be no middleman. The middleman will be replaced by our contract written in Solidity on top of Ethereum blockchain technology. It will execute some if, else like logic, to take necessary action on specific kind of requests. The system is always trust worthy because the contracts are always rigit and can't be modified. This  eliminate the risk of hackers to steal confidential data. This system promotes transparency, efficieny, and user empowerment.


Following key features are provided in Univault:

- **Off-chain Storage**: Files kept off the blockchain, with only verification codes stored on-chain
- **Role-Based Access**: OpenZeppelin's AccessControl to manage admin, creater, and student roles
- **Gas-Optimized Revocation**: Using bitmap-based revocation system for low cost updates
- **DID Support**: Students can self-manage 
- **Verifiable Integrity**: keccak256 hashing for proof system
- **Extensible Design**: Keeping the structure modular for future developments

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

## Dependencies or setup instructions

### Dependencies
- Solidity Compiler
- OpenZeppelin Contracts
    - import "@openzeppelin/contracts/access/Ownable.sol";
    - import "@openzeppelin/contracts/utils/Counters.sol";
- MetaMask
   

The fastest way to demo UniVault without any local installation.

### Setup
- Open Remix IDE at https://remix.ethereum.org
- Create a new Workspace
    - Click on Workspace -> Create Workspace
- Add your contract files
    - Create a new file: `UniVault.sol`
    - Paste the contract code
- Set Solidity compiler version to 0.8.18 or higher
    - Click on the Solidity Compiler tab
    - Select the preferred version  
- Compile contract by clicking on Compile button
- Deploy the Contract
- Interact with the contract
    - After deploying the contract, the functions will be visible.
    - You can choose any function, give the inputs and click to make a call.
- Debug
    - Logs can be seen on terminal to debug the issues.
### How to deploy

- Open Remix
- Open Solidity Files
- Choose Compiler -> Click on Compile Button
- Install MetaMask to manage the crypto wallet
- Add funds
- Click on deploy & Run
- MetaMask → select UniVault → set any constructor params → Deploy


While deploying, it will ask for an input for the parameter, the admin. use the following:
```solidity
// Constructor parameter:
admin: 0x0000000000000000000000000000000000000000
// (Passing zero address makes deployer the admin)
```

### How to use
- There will be different functions, each having different input and output
- Some functions could be defined by the user, some could be inherited

1. Add an issuer
    - input: address of the admin account
    - Click: transact
    - Expect: Event CreaterAdded(0x5B38…bdC4)

2. Student sets DID
    - Input: "did:key:zStudentExample123"
    - Click: transact 
    - Expect: DIDIsSet(...)

3. Issue a credential
    - Input: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 0xe4d6d3299804d5555bc2a46af78cd89187af7c737b2717d0cd5d443858e6dbd9 "ipfs://bafybeigdyrsamplecid1234567890abcdef" 0
    - Click: transact
    - Expect: CredentialCreated(...)

Currently only three functions has been implemented. We are working on rest of them.


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
