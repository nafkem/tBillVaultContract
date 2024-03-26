// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./ERC20Token.sol";
import "./tBillToken.sol";

contract TBillVault is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public owner;

    struct Investor {
        uint256 depositedAmount; // Amount of USDC/cUSD deposited by the investor
        uint256 tbillBalance; // TBILL TOKEN balance of the investor
        uint256 yieldEarned; // Yield earned by the investor
        uint256 lastYieldUpdate; // Timestamp of the last yield update
    }

    mapping(address => Investor) public investors;
    address[] public investorAddresses; // Array to store investor addresses

    address public cusdcToken;
    address public tbillToken;

    uint256 public yieldRate; // Annual yield rate in percentage
    uint256 public lastYieldUpdate; // Timestamp of the last global yield update

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Redeem(address indexed account, uint256 amount);
    event YieldUpdated(uint256 newRate);

    constructor(address _cusdcToken, address _tbillToken, uint256 _yieldRate) {
        cusdcToken = (_cusdcToken);
        tbillToken = (_tbillToken);
        yieldRate = _yieldRate;
        lastYieldUpdate = block.timestamp;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        // Transfer USDC/cUSD from user to this contract
        IERC20 cusdcContract = IERC20(cusdcToken);
        TBILLToken tBillContract = TBILLToken(tbillToken);
        require(
            cusdcContract.transferFrom(msg.sender, address(this), amount),
            "failed to transfer"
        );
        // Update investor's records
        Investor storage investor = investors[msg.sender];
        investor.depositedAmount += amount;
        investor.tbillBalance += amount;
        investor.lastYieldUpdate = block.timestamp;
        // Mint TBILL tokens to the depositor based on the deposited amount
        tBillContract.mint(msg.sender, amount);

        if (investor.depositedAmount > 0) {
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
        // Update investor's records
        investors[msg.sender].depositedAmount -= amount;
        investors[msg.sender].tbillBalance -= amount;
        investors[msg.sender].lastYieldUpdate = block.timestamp;
        // Transfer USDC/cUSD from this contract to user
        cusdcContract.safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }

    function redeem(uint256 amount) external nonReentrant {
        require(amount > 0, "Redeem amount must be greater than zero");
        require(
            investors[msg.sender].tbillBalance >= amount,
            "Insufficient TBILL balance"
        );
        investors[msg.sender].depositedAmount += amount;
        investors[msg.sender].tbillBalance -= amount;
        investors[msg.sender].lastYieldUpdate = block.timestamp;
        // Transfer USDC/cUSD from this contract to user
        cusdcContract.transfer(msg.sender, amount);
        emit Redeem(msg.sender, amount);
    }

    function updateYield() external {
        uint256 elapsedTime = block.timestamp - lastYieldUpdate;
        uint256 totalYield = 0;
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            Investor storage investor = investors[investorAddresses[i]];
            uint256 yieldEarned = (investor.depositedAmount *
                yieldRate *
                elapsedTime) / (90 days * 100);
            investor.yieldEarned += yieldEarned;
            totalYield += yieldEarned;
        }

        lastYieldUpdate = block.timestamp;

        emit YieldUpdated(totalYield);
    }
}
