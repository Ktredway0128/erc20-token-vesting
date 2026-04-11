# TOKEN VESTING CONTRACT

[![Verified on Etherscan](https://img.shields.io/badge/Etherscan-Verified-brightgreen)](https://sepolia.etherscan.io/address/0x81F71D5D73383750C9d4BCe65C493A55BA887ecB#code)

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Solidity](https://img.shields.io/badge/Solidity-0.8.19-blue)
![Hardhat](https://img.shields.io/badge/Built%20with-Hardhat-yellow)

Built by [Kyle Tredway Development](https://kyle-tredway-portfolio.netlify.app/) — professional Solidity smart contract packages for Web3 companies.

A secure and production-ready ERC-20 token vesting contract built with Solidity, OpenZeppelin, and Hardhat.

> ⚠️ These contracts have not been professionally audited. A full security audit is strongly recommended before any mainnet deployment.


This project demonstrates the full lifecycle of a token vesting system including:

Smart contract development
Automated testing
Deployment scripting
Security best practices

This repository represents the second package in a Web3 infrastructure suite, designed to work alongside the ERC-20 Token Launch contract to provide investor and team token vesting capabilities.


## PROJECT GOALS

The purpose of this project is to demonstrate how a modern token vesting contract should be designed for real-world use.

The contract includes common features required by token vesting systems:

Cliff and linear vesting schedules
Multiple schedules per beneficiary
Admin controlled revocation
Fair beneficiary protection on revocation
Role-based administrative permissions
Event logging for transparency

These patterns are widely used in production Web3 applications.


## SMART CONTRACT FEATURES

VESTING SCHEDULES

Admins can create individual vesting schedules for any beneficiary.
Each schedule defines a total amount, start time, cliff period, and vesting duration.
Every schedule creation emits a VestingScheduleCreated event.

CLIFF PERIOD

Tokens are locked until the cliff period has passed.
No tokens can be released before the cliff regardless of elapsed time.

LINEAR VESTING

After the cliff, tokens are released linearly over the remaining duration.
Beneficiaries can claim their available tokens at any time after the cliff.

MULTIPLE SCHEDULES PER BENEFICIARY

A single address can hold multiple independent vesting schedules.
Each schedule is tracked by a unique ID derived from the holder address and index.

REVOCATION

Admins can revoke a vesting schedule at any time.
Unvested tokens are returned to the contract upon revocation.
Tokens that vested before revocation remain claimable by the beneficiary.

The exact vested amount is frozen at the moment of revocation using a
vestedAtRevocation field stored on the schedule. This prevents the releasable
amount from continuing to climb after revocation, ensuring beneficiaries can
only ever claim what was legitimately vested before the schedule was cancelled.

ROLE-BASED PERMISSIONS

Administrative actions are protected using OpenZeppelin's AccessControl.
Roles include:

ROLE                DESCRIPTION

DEFAULT_ADMIN_ROLE  Can manage roles
ADMIN_ROLE          Can create schedules, revoke, and withdraw

ADMIN ROLE PROTECTION

The contract prevents the admin from accidentally renouncing the DEFAULT_ADMIN_ROLE.
This ensures the contract can never be permanently locked without an administrator.

TOKEN WITHDRAWAL

Admins can withdraw any tokens not locked in an active vesting schedule.
This allows recovery of excess or unallocated tokens.

EVENT TRACKING

The contract emits events for important actions:

VestingScheduleCreated
TokensReleased
VestingRevoked

Events make it easier for applications, dashboards, and explorers to monitor contract activity.


## TECHNOLOGY STACK

This project was built using the following tools:

Solidity – Smart contract programming language

Hardhat – Ethereum development environment

Ethers.js – Contract interaction library

OpenZeppelin Contracts – Secure smart contract libraries

Mocha & Chai – JavaScript testing framework

Alchemy – Ethereum RPC provider

Sepolia Test Network – Deployment environment


## PROJECT STRUCTURE

contracts/
    TokenVesting.sol

scripts/
    deploy-token.js
    deploy-vesting.js

test/
    TokenVesting.test.js

hardhat.config.js
.env

CONTRACTS

Contains the vesting smart contract implementation.

SCRIPTS

Contains deployment scripts for both the token and vesting contracts.

TESTS

Contains automated tests verifying all major contract behaviors.


## SMART CONTRACT ARCHITECTURE

The TokenVesting contract extends the following OpenZeppelin modules:

AccessControl
ReentrancyGuard
SafeERC20

This modular architecture provides strong security and reusable functionality while keeping the contract easy to audit.


## INSTALLATION

### CLONE THE REPOSITORY:

git clone https://github.com/Ktredway0128/token-vesting

cd token-vesting

### INSTALL DEPENDENCIES:

npm install

### COMPILE THE CONTRACT:

npx hardhat compile

### RUN THE TEST SUITE:

npx hardhat test

### THE TESTS VALIDATE:

Vesting schedule creation
Cliff enforcement
Linear token release
Full duration release
Admin revocation
Beneficiary protection after revocation
Token withdrawal
Edge cases and access control
renounceRole protection


## ENVIRONMENT SETUP

Create a .env file in the root directory.

ALCHEMY_API_URL=YOUR_SEPOLIA_RPC_URL

DEPLOYER_PRIVATE_KEY=YOUR_PRIVATE_KEY

ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY

These values allow Hardhat to:

Connect to the Sepolia network
Sign transactions using the deployer's wallet


## DEPLOYMENT

This contract requires the ERC-20 token to be deployed first.
The token address is passed into the vesting contract constructor.

### STEP 1 - Deploy the token:

npx hardhat run scripts/deploy-token.js --network sepolia

### STEP 2 - Copy the token address from the console output and paste it into deploy-vesting.js

### STEP 3 - Deploy the vesting contract:

npx hardhat run scripts/deploy-vesting.js --network sepolia

The deployment script performs the following steps:

Retrieves the deployer wallet
Creates the contract factory
Deploys the vesting contract with the token address
Waits for confirmation
Outputs the deployed contract address

### SEPOLIA TESTNET DEPLOYMENT

| Contract | Address | Etherscan |
|----------|---------|-----------|
| SampleToken | `0x036150039c33b1645080a9c913f96D4c65ccca48` | [View on Etherscan](https://sepolia.etherscan.io/address/0x036150039c33b1645080a9c913f96D4c65ccca48#code) |
| TokenVesting | `0x81F71D5D73383750C9d4BCe65C493A55BA887ecB` | [View on Etherscan](https://sepolia.etherscan.io/address/0x81F71D5D73383750C9d4BCe65C493A55BA887ecB#code) |

Deployed: 2026-03-26


## SECURITY PRACTICES

The contract uses well-established patterns from OpenZeppelin including:

ReentrancyGuard on all token release functions
SafeERC20 for safe token transfers
Role-based permissions
Fair beneficiary protection on revocation
Audited contract libraries

These are common practices used in production smart contracts.


## EXAMPLE USE CASES

This vesting architecture can support many types of projects:

Employee token compensation
Investor token lockups
Founder vesting schedules
Advisor token grants
DAO contributor rewards


## FUTURE ENHANCEMENTS

This project serves as the second layer in a larger Web3 infrastructure package.

Possible upgrades include:

Airdrop contract integration
Staking rewards
Governance (DAO voting)
Treasury management
Upgradeable proxy contracts


## AUTHOR

Kyle Tredway

Smart Contract Developer / Token Launch Specialist

License

MIT License