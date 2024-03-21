// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "./IERC20.sol";
import "./tBillToken.sol";

contract TBillVault is ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct Investor {
        uint256 depositedAmount; // Amount of USDC/cUSD deposited by the investor
        uint256 tbillBalance; // TBILL TOKEN balance of the investor
        uint256 yieldEarned; // Yield earned by the investor
        uint256 lastYieldUpdate; // Timestamp of the last yield update
    }

    mapping(address => Investor) public investors;
    address[] public investorAddresses; // Array to store investor addresses

    IERC20 public cusdcToken;
    TBILLToken public tbillToken;

    uint256 public yieldRate; // Annual yield rate in percentage
    uint256 public lastYieldUpdate; // Timestamp of the last global yield update

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Redeem(address indexed account, uint256 amount);
    event YieldUpdated(uint256 newRate);

    constructor(address _cusdcToken, address _tbillToken, uint256 _yieldRate) {
        cusdcToken = IERC20(_cusdcToken);
        tbillToken = TBILLToken(_tbillToken);
        yieldRate = _yieldRate;
        lastYieldUpdate = block.timestamp;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        // Transfer USDC/cUSD from user to this contract
        cusdcToken.safeTransferFrom(msg.sender, address(this), amount);
        // Mint TBILL tokens to the depositor based on the deposited amount
        tbillToken.mint(msg.sender, amount);
        // Update investor's records
        Investor storage investor = investors[msg.sender];
        investor.depositedAmount += amount;
        investor.tbillBalance += amount;
        investor.lastYieldUpdate = block.timestamp;

        if (investor.depositedAmount == amount) {
            // If this is the first deposit for the investor, add their address to the array
            investorAddresses.push(msg.sender);
        }

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(
            investors[msg.sender].tbillBalance >= amount,
            "Insufficient TBILL balance"
        );
        // // Burn TBILL tokens from the withdrawer
        tbillToken.burn(msg.sender, amount);
        // Transfer USDC/cUSD from this contract to user
        cusdcToken.safeTransfer(msg.sender, amount);
        // Update investor's records
        investors[msg.sender].depositedAmount -= amount;
        investors[msg.sender].tbillBalance -= amount;
        investors[msg.sender].lastYieldUpdate = block.timestamp;

        emit Withdraw(msg.sender, amount);
    }

    function redeem(uint256 amount) external nonReentrant {
        require(amount > 0, "Redeem amount must be greater than zero");
        require(
            investors[msg.sender].tbillBalance >= amount,
            "Insufficient TBILL balance"
        );
        // Burn TBILL tokens from the redeemer
        // tbillToken.burn(msg.sender, amount);
        // Transfer USDC/cUSD from this contract to user
        cusdcToken.safeTransfer(msg.sender, amount);
        // Update investor's records
        investors[msg.sender].depositedAmount -= amount;
        investors[msg.sender].tbillBalance -= amount;
        investors[msg.sender].lastYieldUpdate = block.timestamp;

        emit Redeem(msg.sender, amount);
    }

    function updateYield() external {
        uint256 elapsedTime = block.timestamp - lastYieldUpdate;
        uint256 totalYield = 0;
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            Investor storage investor = investors[investorAddresses[i]];
            uint256 yieldEarned = (investor.depositedAmount *
                yieldRate *
                elapsedTime) / (365 days * 100);
            investor.yieldEarned += yieldEarned;
            totalYield += yieldEarned;
        }

        lastYieldUpdate = block.timestamp;

        emit YieldUpdated(totalYield);
    }
}
