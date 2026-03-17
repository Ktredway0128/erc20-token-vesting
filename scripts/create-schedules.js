// SPDX-License-Identifier: MIT
// Script to create vesting schedules for TokenVesting contract

const hre = require("hardhat");

async function main() {
    // Get deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log("Creating schedules with account:", deployer.address);

    // Paste your deployed contract addresses here
    const tokenAddress = "YOUR_DEPLOYED_TOKEN_ADDRESS_HERE";
    const vestingAddress = "YOUR_DEPLOYED_VESTING_ADDRESS_HERE";

    // Get contract instances
    const token = await hre.ethers.getContractAt("SampleToken", tokenAddress);
    const vesting = await hre.ethers.getContractAt("TokenVesting", vestingAddress);

    // Define vesting schedules
    // Fill in real beneficiary addresses and amounts for your client
    const schedules = [
        {
            beneficiary: "BENEFICIARY_ADDRESS_1",
            amount: hre.ethers.utils.parseEther("10000"),
            start: Math.floor(Date.now() / 1000),              // starts now
            cliffDuration: 180 * 24 * 60 * 60,                 // 6 months in seconds
            duration: 730 * 24 * 60 * 60                        // 2 years in seconds
        },
        {
            beneficiary: "BENEFICIARY_ADDRESS_2",
            amount: hre.ethers.utils.parseEther("5000"),
            start: Math.floor(Date.now() / 1000),              // starts now
            cliffDuration: 90 * 24 * 60 * 60,                  // 3 months in seconds
            duration: 365 * 24 * 60 * 60                        // 1 year in seconds
        },
        {
            beneficiary: "BENEFICIARY_ADDRESS_3",
            amount: hre.ethers.utils.parseEther("8000"),
            start: Math.floor(Date.now() / 1000),              // starts now
            cliffDuration: 365 * 24 * 60 * 60,                 // 1 year in seconds
            duration: 1460 * 24 * 60 * 60                       // 4 years in seconds
        },
    ];

    // Calculate total tokens needed
    const totalAmount = schedules.reduce(
        (sum, s) => sum.add(s.amount),
        hre.ethers.BigNumber.from(0)
    );
    console.log("Total tokens needed:", hre.ethers.utils.formatEther(totalAmount));

    // Check deployer has enough tokens
    const deployerBalance = await token.balanceOf(deployer.address);
    console.log("Deployer balance:", hre.ethers.utils.formatEther(deployerBalance));
    
    if (!deployerBalance.gte(totalAmount)) {
        throw new Error("Not enough tokens in deployer wallet");
    }

    // Create each schedule
    for (const schedule of schedules) {

        // Fund vesting contract for this schedule
        await token.transfer(vesting.address, schedule.amount);
        console.log(`Funded vesting contract with ${hre.ethers.utils.formatEther(schedule.amount)} tokens`);

        // Create the vesting schedule
        await vesting.createVestingSchedule(
            schedule.beneficiary,
            schedule.amount,
            schedule.start,
            schedule.cliffDuration,
            schedule.duration
        );

        console.log(`Created schedule for ${schedule.beneficiary}`);
        console.log(`Amount: ${hre.ethers.utils.formatEther(schedule.amount)} tokens`);
        console.log(`Cliff: ${schedule.cliffDuration / (24 * 60 * 60)} days`);
        console.log(`Duration: ${schedule.duration / (24 * 60 * 60)} days`);
        console.log("---");
    }

    console.log("All schedules created successfully!");
    console.log("Total vesting contract balance:", hre.ethers.utils.formatEther(await token.balanceOf(vesting.address)), "tokens");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});