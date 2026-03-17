// SPDX-License-Identifier: MIT
// Deploy script for TokenVesting using Hardhat

// Import Hardhat runtime environment
const hre = require("hardhat");

async function main() {
    // Get deployer account
    const [deployer] = await hre.ethers.getSigners();

    // Show which account deploys
    console.log("Deploying contract with account:", deployer.address);

    // Get contract factory
    const TokenVesting = await hre.ethers.getContractFactory("TokenVesting");

    // The token address that this vesting contract will manage
    // Replace this with your deployed SampleToken address
    const tokenAddress = "BENEFICIARY_ADDRESS_2";

    // Deploy the contract
    const vesting = await TokenVesting.deploy(tokenAddress);

    // Wait until deployment is confirmed
    await vesting.deployed();

    // Show deployed contract address
    console.log("TokenVesting deployed to:", vesting.address);
}

// Run main and handle errors
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});