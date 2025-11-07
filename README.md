# UniVault — Decentralized University Credential Registry (Group 31)

## 1) Description of the project
UniVault is a lightweight, gas‑aware smart‑contract design for issuing and verifying university credentials on Ethereum. It keeps sensitive documents off‑chain and anchors only a content hash (keccak256) and a URI (e.g., an IPFS CID) on‑chain, allowing verifiers to prove integrity without exposing private data. Roles are defined with AccessControl: an admin onboards universities as issuers; issuers create and revoke credentials; students self‑manage a DID string for discovery and linking. Revocation uses a per‑issuer bitmap (one bit per credential), enabling constant‑time, low‑cost status updates. A verifier fetches the off‑chain file, recomputes its hash, and calls `verifyCredential` to confirm the credential exists, isn’t revoked or expired, and matches the expected hash. This draft focuses on the on‑chain data model and external function signatures so the team can safely add or remove features later (e.g., schema registry, EIP‑712 attestations, ZK proofs, or a UI). The design is demo‑able end‑to‑end in Remix using the JavaScript VM.

---

## 2) Dependencies or setup instructions

### Fastest path (no local installs): Remix
- Use Remix IDE in your browser.
- Solidity compiler: **0.8.20+**.
- Create a file `UniVault.sol` and paste the draft contract.
- Environment: **JavaScript VM** (Remix default).

### Local toolchain (for later)
- Node.js **20.x** and npm **10.x**
- **Hardhat**, **Ethers.js**, **OpenZeppelin Contracts**

Typical flow once the repo exists:
```bash
npm install
npx hardhat compile
# example:
npx hardhat run scripts/deploy_univault.js --network sepolia
```

---

## 3) How to use or deploy

### Remix (JavaScript VM) quick demo

**Compile & Deploy**
- Compile `UniVault.sol` with Solidity **0.8.20+**.
- Deploy & Run → Environment = **JavaScript VM** → choose any default account.
- Constructor (`admin`): `0x0000000000000000000000000000000000000000`
  - (passing zero makes the **deployer** the admin) → **Deploy**.

**Add an issuer (admin‑only)**
- As the admin account, call: `addIssuer(<issuerAddress>)`.

**Student sets DID**
- Switch to a different account (student) and call:  
  `setMyDID("did:key:zStudentExample123")`
- Read back with: `getDID(<studentAddress>)`.

**Issue a credential (issuer‑only)**
```text
issueCredential(
  <studentAddress>,                 // address (no quotes)
  <bytes32 docHash>,                // e.g., 0xe4d6d3299804...e6dbd9
  "ipfs://bafy...samplecid",        // string (quoted)
  0                                 // uint64 (no quotes) or Unix expiry
)
```
- Note the returned `credId` (e.g., 1). If Remix hides returns, read the **CredentialIssued** event or call `getCredential(1)`.

**Verify & revoke**
- `verifyCredential(credId, <same docHash>)` → `(true, "OK")` if valid.
- `revokeCredential(credId)` (issuer) → `isRevoked(credId)` → `true`; then  
  `verifyCredential(credId, <hash>)` → `(false, "REVOKED")`.

**Input tips**
- **Addresses** = no quotes; **Strings** = quoted; **Numbers** = no quotes.
- In Remix, always call functions on the latest deployed **UniVault** instance.

---

## 4) Functions

| Function | Who can call | Inputs (order matters) | Notes |
|---|---|---|---|
| `constructor(address admin)` | deployer | `admin` or `0x000...0000` | If admin is zero, deployer becomes admin. |
| `addIssuer(address university)` | admin only | `university` | Grants `ISSUER_ROLE`. |
| `removeIssuer(address university)` | admin only | `university` | Revokes `ISSUER_ROLE`. |
| `setMyDID(string did)` | any | `"did:..."` | Stores caller’s DID. |
| `getDID(address student)` | view | student address | Returns DID string. |
| `issueCredential(address subject, bytes32 docHash, string uri, uint64 expiresAt)` | issuer only | `(subject, docHash, uri, expiresAt)` | Emits `CredentialIssued(credId, …)`. Return value not visible to EOA; use event/logs. |
| `getCredential(uint256 credId)` | view | `credId` | Anyone can read. |
| `isRevoked(uint256 credId)` | view | `credId` | Bitmap lookup. |
| `revokeCredential(uint256 credId)` | issuer only | `credId` | Emits `CredentialRevoked`. |
| `verifyCredential(uint256 credId, bytes32 providedDocHash)` | view | `(credId, providedDocHash)` | Returns `(isValid, reason)` where `reason ∈ {"OK","NOT_FOUND","REVOKED","EXPIRED","HASH_MISMATCH"}`. |

---
