# UniVault | University Credential Management System

**Group 31**

---

## Description of the project

This is a lightweight and gas efficient smart contract system to issue and verify university credentials on Ethereum. Storing only cryptographic proofs on chain makes it privacy protected verification and keeps sensitive data off-chain.

The idea of UniVault aims to change the credential management system for the universities and colleges by using latest coding technologies making a secure, and centralized system. The system should be very efficient for which will allow to save educational data. These days, students like us have to deal with many challenges during the need to fetch academic records because the process is very time taking, manual and consumes a lot of money. Also, the old systems are easily to get risk because of hackers. We will solve these problems by providing students a very secure system where they can access their academic data by themself whenever they want without any human or manual interaction, saving large amount of time and money.

Generally, when a user requests for the records like transcripts from the universities, there will be middlemans who are employees of the university. But, with UniVault, there will be no middleman. The middleman will be replaced by our contract written in Solidity on top of Ethereum blockchain technology. It will execute some if, else like logic, to take necessary action on specific kind of requests. The system is always trust worthy because the contracts are always rigid and can't be modified. This eliminate the risk of hackers to steal confidential data. This system promotes transparency, efficiency, and user empowerment.

Following key features are provided in Univault:

- **Off-chain Storage**: Files kept off the blockchain via IPFS (Pinata), with only verification codes stored on-chain
- **Role-Based Access**: OpenZeppelin's AccessControl to manage admin, issuer, and verifier roles
- **Gas-Optimized Revocation**: Using bitmap-based revocation system for low cost updates
- **DID Support**: Students can self-manage their decentralized identifiers
- **Verifiable Integrity**: keccak256 hashing for proof system
- **Extensible Design**: Keeping the structure modular for future developments
- **Web-Based UI**: Minimal, modern interface for credential management

### On-Chain Components
- Document hash (keccak256)
- Storage location link (IPFS URI)
- Issuer and student addresses
- Expiration timestamp
- Per issuer revocation bitmap
- DID anchors for self-sovereign identity

### Off-Chain Components
- Credential documents (PDFs, images, JSON)
- Stored on IPFS via Pinata

### Roles
- **Admin**: Onboards universities as issuers, manages verifiers
- **Issuer**: Issues and revokes credentials
- **Verifier**: Logs verification events on-chain
- **Student**: Self-manages DID string for linking credentials

---

## Dependencies or setup instructions

### Dependencies

#### Smart Contract
- **Solidity Compiler** (v0.8.20+)
    - It's a tool that converts the high level solidity (.sol) code into byte code which makes it executable on Ethereum Virtual Machine (EVM)
- **OpenZeppelin Contracts**
    - `import "@openzeppelin/contracts/access/AccessControl.sol";`
    - They are the building blocks of complex smart contracts

#### Frontend UI
- **Modern Web Browser** (Chrome, Firefox, Edge, Brave)
- **MetaMask Browser Extension** → https://metamask.io/
    - It's a crypto wallet system. 
    - It's mostly use for Ethereum and EVM
    - It's also an gateway to dApps
    - It is also responsible for Network Management

#### External Services
- **Pinata Account** → https://pinata.cloud/
    - IPFS pinning service
    - Create a free account
    - Generate an API JWT token

---

## Prerequisites & Installation

### Prerequisites
- **Node.js** (v16 or higher)
- **npm** (Node Package Manager)
- **MetaMask** Browser Extension

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd UniVault
   ```
2. Install dependencies:
   ```bash
   npm install
   ```

---

## Local Development (Recommended)

This project is configured with **Hardhat** for a robust local development environment.

### 1. Start Local Blockchain
Start a local Hardhat node. This will give you 20 test accounts with 10,000 ETH each.
```bash
npx hardhat node
```
*Keep this terminal running.*

### 2. Deploy Contracts
Open a new terminal and deploy the contracts to your local network:
```bash
npx hardhat run scripts/deploy.js --network localhost
```
Copy the **Contract Address** from the output (e.g., `0x5FbDB2315678afecb367f032d93F642f64180aa3`).

### 3. Configure MetaMask
1. Open MetaMask and click the network dropdown.
2. Select **"Add a network manually"**.
3. Enter these details:
   - **Network Name**: Hardhat Localhost
   - **RPC URL**: `http://127.0.0.1:8545`
   - **Chain ID**: `31337`
   - **Currency Symbol**: `ETH`
4. Click **Save**.

### 4. Import Test Account
1. Look at the terminal running `npx hardhat node`.
2. Copy the **Private Key** of Account #0 (or any other account).
3. In MetaMask, click your account icon -> **Import Account**.
4. Paste the private key.
5. You should now see 10,000 ETH.

### 5. Connect UI
1. Open `index.html` in your browser (or serve it using `python -m http.server 8000`).
2. Connect your wallet and ensure you are on **Hardhat Localhost**.
3. Paste the **Contract Address** you copied earlier.
4. You are ready to test!

---

## Setup Instructions

### Part 1: MetaMask & Sepolia Testnet Setup

#### 1. Install MetaMask
1. Visit https://metamask.io/download/
2. Install the browser extension for your browser
3. Create a new wallet or import existing one
4. Save your Secret Recovery Phrase

#### 2. Add Sepolia Testnet to MetaMask
1. Open MetaMask extension
2. Click the network dropdown at the top (shows "Ethereum Mainnet" by default)
3. Click "Add Network" or "Add a network manually"
4. Enter the following Sepolia network details:
   ```
   Network Name: Sepolia
   RPC URL: https://rpc.sepolia.org
   Chain ID: 11155111
   Currency Symbol: SepoliaETH
   Block Explorer: https://sepolia.etherscan.io
   ```
5. Click "Save"
6. Switch to Sepolia network from the dropdown

#### 3. Get Sepolia Test ETH
You need test ETH to deploy contracts and pay for transactions. https://faucet.metana.io/

**Steps:**
1. Copy your MetaMask wallet address 
2. Paste your address and request test ETH
3. Check MetaMask after sometime, SepoliaETH balance should be visible now

---

### Part 2: Smart Contract Deployment

#### Using Remix IDE

1. **Open Remix**
   - Visit https://remix.ethereum.org/

2. **Create Workspace**
   - Click "File Explorer" icon
   - Click "Create New Workspace"
   - Name it "UniVault"

3. **Add Contract File**
   - Right-click on `contracts` folder → New File
   - Name it `UniVault.sol`
   - Paste the smart contract code from the provided `.sol` file

4. **Compile Contract**
   - Click "Solidity Compiler" icon in left sidebar
   - Select compiler version: `0.8.20` or higher
   - Enable "Auto compile" (optional)
   - Click "Compile UniVault.sol"
   - Ensure no errors appear

5. **Deploy to Sepolia**
   - Click "Deploy & Run Transactions" icon
   - In "Environment" dropdown, select **"Injected Provider - MetaMask"**
   - MetaMask popup will appear - select Sepolia network and connect
   - Confirm you see your account address and Sepolia balance
   
   - **Constructor Parameter:**
     - Expand "Deploy" section
     - In `ADMIN` field, enter: `0x0000000000000000000000000000000000000000`
     - (Zero address makes deployer the admin automatically)
   
   - Click **"Deploy"** button (orange)
   - MetaMask will pop up requesting transaction approval
   - Click "Confirm" and wait for deployment
   
6. **Copy Contract Address**
   - After deployment, see "Deployed Contracts" section
   - Click the copy icon next to your deployed contract
   - **Save this address** - for the UI!
   - Example: `0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb5`


---

### Part 3: Frontend UI Setup

1. **Download Files**
   - Save `index.html`, `js_scripts.js`, `styles.css` in the same folder
   - Example: ``~/UniVault/`

2. **Open Terminal/Command Prompt**

3. **Navigate to Your Folder**
   ```bash
   cd ~/UniVault/
   ```

4. **Start Local Server**
   - **Python 3.x**:
     ```bash
     python -m http.server 8000
     ```

5. **Open in Browser**
   - Visit: http://localhost:8000
   - You should see the UniVault UI
---

### Part 4: Get Pinata JWT Token

1. **Create Pinata Account**
   - Visit https://pinata.cloud/
   - Sign up for free account

2. **Generate API Key**
   - Go to https://app.pinata.cloud/developers/api-keys
   - Click "New Key"
   - Select permissions: **Pin File to IPFS** 
   - Name it: "Demo"
   - Click "Create Key"
   - **IMPORTANT**: Copy the JWT token immediately 
---

## How to Use the UI

### Initial Setup

1. **Open UniVault UI** in your browser (http://localhost:8000)

2. **Connect Wallet**
   - Click "Connect Wallet" button in top-right
   - MetaMask popup appears
   - Select your account and click "Connect"
   - Confirm you're on Sepolia network
   - The "Issuer" field auto-fills with your wallet address

3. **Configure Contract**
   - In "Contract Address" field, paste your deployed contract address
   - In "Pinata JWT" field, paste your API token
   - In "Chain" field, you'll see "sepolia (11155111)" after connecting

### Adding an Issuer (Admin Only)

**Note**: The deployer address is automatically the admin.

1. **Open Remix** 
2. **Call `addIssuer` function**:
   - Input: University/institution wallet address
   - Example: `0x5B38Da6a701c568545dCfcB03FcB875f56beddC4`
3. **Confirm Transaction** in MetaMask
4. Wait for confirmation (~15 seconds)
5. Check event logs for `IssuerAdded`

### Anchoring a DID (Student/Subject)

1. **Switch to student account** in MetaMask
2. **Open Remix** → Connect to deployed contract
3. **Call `anchorMyDID`**:
   - `didURI`: `"did:example:student123"` or any DID format
   - `docHash`: `0xe4d6d3299804d5555bc2a46af78cd89187af7c737b2717d0cd5d443858e6dbd9` (example hash)
4. **Confirm transaction**
5. Event `DIDAnchored` is emitted

### Issuing a Credential

1. **Ensure connected wallet is an issuer** (has ISSUER_ROLE)

2. **Fill in Issue Form**:
   - **Subject Address**: Student's wallet address
     - Example: `0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2`
   - **Credential File**: Choose a PDF, image, or JSON file
   - **Expiry** (optional): Set future date/time, or leave blank for no expiry
   - **Hash Strategy**: 
     - **Recommended**: `keccak256(file bytes)` - most secure
     - Alternative: `keccak256(CID string)` - quick but less secure

3. **Upload to Pinata**:
   - Click "1) Upload to Pinata" button
   - Wait for upload (~2-10 seconds depending on file size)
   - You'll see:
     - **CID**: IPFS content identifier (e.g., `bafybei...`)
     - **Gateway Link**: Click to view file on IPFS
     - **keccak256(bytes)**: Hash of file contents
     - **keccak256(CID)**: Hash of CID string

4. **Issue Credential**:
   - Review the hashes to ensure integrity
   - Click "2) Issue Credential" button (now enabled)
   - MetaMask popup appears
   - **Confirm transaction** (~$0.50-$2 in test ETH)
   - Wait for confirmation
   - You'll see:
     - Transaction hash
     - Credential ID (e.g., `1`, `2`, `3`...)
     - IPFS URI
     - Hash used on-chain

5. **Save the Credential ID** 

### Reading a Credential

1. **Enter Credential ID** in "Credential ID" field
   - Example: `1`

2. **Click "Read" button**

3. **View Details** in "Current Credential" section:
   ```
   docHash: 0xe4d6d3299804d5...
   uri: ipfs://bafybei...
   issuer: 0x5B38Da6...
   subject: 0xAb8483F6...
   issuedAt: 1700000000 (Unix timestamp)
   expiresAt: 0 (never expires) or timestamp
   issuerSeqIndex: 0
   revoked: false
   ```

### Verifying a Credential

1. **Enter Credential ID** (e.g., `1`)

2. **Choose the same file** that was originally issued
   - Click "File to Verify" and select file

3. **Click "Compute & Call verifyCredential"**

4. **View Result**:
   - **VALID (OK)** - File matches, not revoked, not expired
   - **INVALID (NOT_FOUND)** - Credential ID doesn't exist

### Revoking a Credential (Issuer Only)

1. **Ensure connected wallet is the issuer** of this credential

2. **Enter Credential ID** to revoke

3. **Click "Revoke" button** (red, danger button)

4. **Confirm transaction** in MetaMask

5. **Wait for confirmation**
   - You'll see transaction hash
   - Status changes to "revoked: true"

6. **Verify revocation**:
   - Click "Read" button again
   - Should show `revoked: true`
   - Try verifying - should show "INVALID (REVOKED)"

---

## Smart Contract Interface

### Core Functions

#### Admin Functions
```solidity
function addIssuer(address university) external onlyRole(DEFAULT_ADMIN_ROLE)
function removeIssuer(address university) external onlyRole(DEFAULT_ADMIN_ROLE)
```

#### Issuer Functions
```solidity
function issueCredential(
    address subject,
    bytes32 docHash,
    string calldata uri,
    uint64 expiresAt
) external onlyRole(ISSUER_ROLE) returns (uint256 credId)

function revokeCredential(uint256 credId) external onlyRole(ISSUER_ROLE)
```

#### Student/Subject Functions
```solidity
function anchorMyDID(string calldata didURI, bytes32 docHash) external

function setDIDController(address subject, address newController) external

function setDIDURI(address subject, string calldata didURI, bytes32 docHash) external
```

#### Verifier Functions
```solidity
function logVerification(
    uint256 credId,
    bytes32 presentationHash,
    bool success,
    string calldata context
) external onlyRole(VERIFIER_ROLE)
```

#### View Functions (Anyone Can Call)
```solidity
function verifyCredential(uint256 credId, bytes32 providedDocHash) 
    external view returns (bool isValid, string memory reason)

function getCredential(uint256 credId) 
    external view returns (Credential memory)

function getDID(address subject) 
    external view returns (DIDAnchor memory)

function isRevoked(uint256 credId) 
    external view returns (bool)
```

---

## Complete Workflow Example

### Scenario: University Issues Degree Certificate

#### Step 1: Admin Setup
```
1. Deploy contract with admin = deployer address
2. Admin calls addIssuer(universityAddress)
```

#### Step 2: Student Anchors DID (Optional)
```
1. Student connects wallet
2. Calls anchorMyDID("did:key:zStudent123", hashOfDIDDoc)
3. DID is now linked to student's address
```

#### Step 3: University Issues Credential
```
1. University connects as issuer
2. Uploads degree.pdf to Pinata via UI
3. UI shows:
   - CID: bafybeiabc123...
   - keccak256(bytes): 0xe4d6d3...
4. University clicks "Issue Credential"
5. Fills form:
   - Subject: 0xStudentAddress
   - Expiry: 2028-12-31 (or blank)
6. Transaction confirmed
7. Credential ID = 42
```

#### Step 4: Student Shares Credential
```
Student shares two things with verifier:
1. Credential ID: 42
2. Original degree.pdf file
```

#### Step 5: Verifier Checks Credential
```
1. Verifier uses UI or contract directly
2. Uploads degree.pdf
3. Clicks "Verify" with ID 42
4. Smart contract:
   - Computes keccak256(file)
   - Compares with on-chain docHash
   - Checks revocation status
   - Checks expiration
5. Returns: VALID (OK)
```

#### Step 6: University Revokes
```
1. University discovers fraud
2. Calls revokeCredential(42)
3. Bitmap bit is set for this credential
4. All future verifications fail with "REVOKED"
```
