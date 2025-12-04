const hre = require("hardhat");

async function main() {
    const accounts = await hre.ethers.getSigners();

    console.log("\n🔑 Hardhat Test Accounts");
    console.log("=".repeat(80));
    console.log("These accounts are pre-funded with 10,000 ETH each on your local network.\n");

    for (let i = 0; i < Math.min(accounts.length, 5); i++) {
        const account = accounts[i];
        const balance = await hre.ethers.provider.getBalance(account.address);
        const balanceInEth = hre.ethers.formatEther(balance);

        console.log(`Account #${i}:`);
        console.log(`  Address: ${account.address}`);
        console.log(`  Balance: ${balanceInEth} ETH`);

        if (i === 0) {
            console.log(`  Role: Admin (DEFAULT_ADMIN_ROLE, VERIFIER_ROLE)`);
        } else if (i === 1) {
            console.log(`  Role: Issuer (ISSUER_ROLE)`);
        } else if (i === 2) {
            console.log(`  Role: Verifier (VERIFIER_ROLE)`);
        }
        console.log();
    }

    console.log("=".repeat(80));
    console.log("\n💡 To import an account into MetaMask:");
    console.log("   1. Open MetaMask");
    console.log("   2. Click account icon → Import Account");
    console.log("   3. Select 'Private Key'");
    console.log("   4. Get private key from Hardhat node terminal output");
    console.log("   5. Paste and import");
    console.log("\n⚠️  WARNING: These are TEST accounts only. Never use these keys on mainnet!");
    console.log("=".repeat(80) + "\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
