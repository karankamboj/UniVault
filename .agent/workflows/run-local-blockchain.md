---
description: Run local Hardhat blockchain and test UniVault changes
---

# Running Local Hardhat Blockchain for UniVault Testing

This workflow allows you to test your Solidity contract changes on localhost without paying gas fees.

## Prerequisites

Ensure you have completed the initial setup:
```bash
cd /Users/shankamboj/Documents/Study/america\ after\ coming\ here/Projects/blockchain/UniVault
npm install
```

## Step 1: Start Hardhat Node

Open a terminal and start the local blockchain:

// turbo
```bash
cd /Users/shankamboj/Documents/Study/america\ after\ coming\ here/Projects/blockchain/UniVault
npm run node
```

**What to expect:**
- Node starts on `http://127.0.0.1:8545`
- 20 test accounts are displayed with their private keys
- Each account has 10,000 ETH
- Keep this terminal running

## Step 2: Deploy Contract

Open a **new terminal** and deploy the UniVault contract:

// turbo
```bash
cd /Users/shankamboj/Documents/Study/america\ after\ coming\ here/Projects/blockchain/UniVault
npm run deploy
```

**What to expect:**
- Contract compiles and deploys
- Contract address is displayed (e.g., `0x5FbDB2315678afecb367f032d93F642f64180aa3`)
- Roles are automatically granted to test accounts
- **Copy the contract address** - you'll need it for the UI

## Step 3: Configure MetaMask

### Add Hardhat Network to MetaMask:
1. Open MetaMask
2. Click network dropdown → "Add Network" → "Add a network manually"
3. Enter these details:
   - **Network Name:** Hardhat Local
   - **RPC URL:** `http://127.0.0.1:8545`
   - **Chain ID:** `31337`
   - **Currency Symbol:** `ETH`
4. Click "Save"

### Import a Test Account:
1. In MetaMask, click account icon → "Import Account"
2. Select "Private Key"
3. Copy a private key from the Hardhat node terminal (Step 1)
4. Paste and import
5. You should see ~10,000 ETH balance

## Step 4: Test in Browser

1. Open `index.html` in your browser
2. Click **"Connect Wallet"**
3. Select MetaMask and connect
4. Paste the **contract address** from Step 2 into the "Contract Address" field
5. Test your features:
   - Upload a file
   - Enter your Pinata JWT token
   - Issue a credential
   - Verify credentials
   - All transactions are **gas-free** on localhost!

## Step 5: Testing Contract Changes

When you modify `UniVault.sol`:

1. **Stop** the Hardhat node (Ctrl+C in the first terminal)
2. **Recompile** the contract:
   ```bash
   npm run compile
   ```
3. **Restart** the node:
   ```bash
   npm run node
   ```
4. **Redeploy** in the second terminal:
   ```bash
   npm run deploy
   ```
5. **Update** the contract address in your UI
6. **Test** your changes!

## Troubleshooting

### "Nonce too high" error in MetaMask
- MetaMask cached the old blockchain state
- **Fix:** Settings → Advanced → Clear activity tab data

### "Invalid contract address" error
- Make sure you copied the full address from deployment
- Verify you're connected to "Hardhat Local" network in MetaMask

### Contract not responding
- Ensure Hardhat node is still running in terminal 1
- Check that you deployed after starting the node
- Verify the contract address matches the deployment output

## Quick Reference

| Command | Purpose |
|---------|---------|
| `npm run node` | Start local blockchain |
| `npm run deploy` | Deploy contract to localhost |
| `npm run compile` | Compile Solidity contracts |
| `npm run accounts` | Show test account addresses |

**Network Details:**
- RPC URL: `http://127.0.0.1:8545`
- Chain ID: `31337`
- Test ETH per account: `10,000 ETH`
