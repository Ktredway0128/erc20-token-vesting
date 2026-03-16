// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title TokenVesting - Production ERC20 vesting contract
/// @author Kyle Tredway
/// @notice Holds and releases vested ERC20 tokens over time

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TokenVesting is AccessControl, ReentrancyGuard {

    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IERC20 public immutable token;

    uint256 public vestingSchedulesTotalAmount;
    uint256 public vestingSchedulesCount;

    struct VestingSchedule {
        bool initialized;
        address beneficiary;
        uint256 totalAmount;
        uint256 released;
        uint64 start;
        uint64 cliff;
        uint64 duration;
        bool revoked;
    }

    mapping(bytes32 => VestingSchedule) private vestingSchedules;
    mapping(address => uint256) public holdersVestingCount;

    event VestingScheduleCreated(
        bytes32 vestingId,
        address beneficiary,
        uint256 amount
    );

    event TokensReleased(
        bytes32 vestingId, 
        address beneficiary, 
        uint256 amount
    );

    event VestingRevoked(
        bytes32 vestingId, 
        address beneficiary, 
        uint256 returnedAmount
    );

    constructor(address tokenAddress) {

        token = IERC20(tokenAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function createVestingSchedule(
        address beneficiary,
        uint256 amount,
        uint64 start,
        uint64 cliffDuration,
        uint64 duration
    ) external onlyRole(ADMIN_ROLE) {

        require(amount > 0, "Amount must be greater than 0");
        require(cliffDuration <= duration, "Cliff longer than duration");
        require(duration > 0, "Duration must be greater than 0");
        require(getWithdrawableAmount() >= amount, "Not enough tokens");

        bytes32 vestingId = computeVestingIdForAddressAndIndex(
            beneficiary,
            holdersVestingCount[beneficiary]
        );

        uint64 cliff = start + cliffDuration;

        vestingSchedules[vestingId] = VestingSchedule({
            initialized: true,
            beneficiary: beneficiary,
            totalAmount: amount,
            released: 0,
            start: start,
            cliff: cliff,
            duration: duration,
            revoked: false
        });

        vestingSchedulesTotalAmount += amount;
        vestingSchedulesCount++;
        holdersVestingCount[beneficiary]++;

        emit VestingScheduleCreated(vestingId, beneficiary, amount);
    }

    function release(bytes32 vestingId) public nonReentrant {

        VestingSchedule storage schedule = vestingSchedules[vestingId];

        require(schedule.initialized, "Invalid vesting");
        require(
            msg.sender == schedule.beneficiary,
            "Only beneficiary can release"
        );

        uint256 amount = computeReleasableAmount(schedule);
        require(amount > 0, "No tokens available");

        schedule.released += amount;
        vestingSchedulesTotalAmount -= amount;

        token.safeTransfer(schedule.beneficiary, amount);

        emit TokensReleased(vestingId, schedule.beneficiary, amount);
    }

    function revoke(bytes32 vestingId) external onlyRole(ADMIN_ROLE) {
        VestingSchedule storage schedule = vestingSchedules[vestingId];

        require(schedule.initialized, "Invalid vesting");
        require(!schedule.revoked, "Already revoked");

        
        uint256 vested = computeReleasableAmount(schedule); // amount beneficiary can claim
        uint256 unreleased = schedule.totalAmount - schedule.released - vested; // only unvested
        vestingSchedulesTotalAmount -= unreleased; // only reduce for unvested tokens

        schedule.revoked = true;

        emit VestingRevoked(vestingId, schedule.beneficiary, unreleased);
    }

    function computeReleasableAmount(VestingSchedule memory schedule)
        public
        view
        returns (uint256)
    {
        if (block.timestamp < schedule.cliff) {
            return 0;
        }

        if (block.timestamp >= schedule.start + schedule.duration) {
            return schedule.totalAmount - schedule.released;
        }

        uint256 vested = (schedule.totalAmount *
            (block.timestamp - schedule.start)) / schedule.duration;


        return vested - schedule.released;
    }

    function computeVestingIdForAddressAndIndex(
        address holder,
        uint256 index
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    function getWithdrawableAmount() public view returns (uint256) {
        return token.balanceOf(address(this)) - vestingSchedulesTotalAmount;
    }

    function getVestingSchedule(bytes32 vestingId)
        external
        view
        returns (VestingSchedule memory)
    {
        return vestingSchedules[vestingId];
    }

    function withdraw(uint256 amount) external onlyRole(ADMIN_ROLE) {
        require(getWithdrawableAmount() >= amount, "Not enough free tokens");
        token.safeTransfer(msg.sender, amount);
    }
}