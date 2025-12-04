const hre = require("hardhat");

async function main() {
    console.log("Deploying UniVault contract...");

    // Get the deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying with account:", deployer.address);

    // Deploy the contract
    const UniVault = await hre.ethers.getContractFactory("UniVault");
    const uniVault = await UniVault.deploy(deployer.address);

    await uniVault.waitForDeployment();

    const contractAddress = await uniVault.getAddress();
    console.log("\n✅ UniVault deployed to:", contractAddress);

    // Grant roles to test accounts for easier testing
    const accounts = await hre.ethers.getSigners();

    if (accounts.length > 1) {
        console.log("\n🔑 Granting roles to test accounts...");

        // Grant ISSUER_ROLE to admin (account[0]) for easier testing
        const ISSUER_ROLE = await uniVault.ISSUER_ROLE();
        const tx0 = await uniVault.addIssuer(deployer.address);
        await tx0.wait();
        console.log("   ISSUER_ROLE granted to (Admin):", deployer.address);

        // Grant ISSUER_ROLE to account[1] as well
        const tx1 = await uniVault.addIssuer(accounts[1].address);
        await tx1.wait();
        console.log("   ISSUER_ROLE granted to:", accounts[1].address);

        // Grant VERIFIER_ROLE to account[2] if exists
        if (accounts.length > 2) {
            const VERIFIER_ROLE = await uniVault.VERIFIER_ROLE();
            const tx2 = await uniVault.grantRole(VERIFIER_ROLE, accounts[2].address);
            await tx2.wait();
            console.log("   VERIFIER_ROLE granted to:", accounts[2].address);
        }
    }

    console.log("\n📋 Setup Summary:");
    console.log("=".repeat(60));
    console.log("Contract Address:", contractAddress);
    console.log("Admin Account:", deployer.address);
    console.log("\n⚙️  Next Steps:");
    console.log("1. Copy the contract address above");
    console.log("2. Open index.html in your browser");
    console.log("3. Connect MetaMask to Hardhat network (localhost:8545)");
    console.log("4. Paste the contract address in the 'Contract Address' field");
    console.log("5. Start testing your changes!");
    console.log("=".repeat(60));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
