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
    uint256 constant yieldRate = 0.005 * 1e18; // 0.5% represented in 18 decimal places
    uint256 constant maturityDuration = 30 days;

    struct Investor {
        uint256 depositedAmount;
        uint256 tbillBalance;
        uint256 yieldEarned;
        uint256 lastYieldUpdate;
    }
    mapping(address => Investor) public investors; //store investor data using a mapping
    address[] public investorAddresses; //to store investor addresses using an array
    address public cusdcToken; // store the address of the USDC/cUSD token contract
    address public tbillToken; // store the address of the TBILL token contract
    uint256 public lastYieldUpdate; //store the timestamp of the last global yield update

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Redeem(address indexed account, uint256 amount);
    event YieldUpdated(uint256 newRate);

    constructor(address _cusdcToken, address _tbillToken) {
        cusdcToken = _cusdcToken; //Assigns the address of the USDC/cUSD token contract
        tbillToken = _tbillToken; //// Assigns the address of the TBILL token contract
        lastYieldUpdate = block.timestamp; // Sets the timestamp of the last yield update to the current block timestamp
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero"); //the deposit amount to be greater than zero
        IERC20 cusdcContract = IERC20(cusdcToken); //instance of the IERC20 interface for the USDC/cUSD token
        TBILLToken tbillContract = TBILLToken(tbillToken); // instance of the TBILLToken contract
        require(
            cusdcContract.transferFrom(msg.sender, address(this), amount),
            "failed to transfer"
        );
        // Transfers funds from the investor to the contract
        Investor storage investor = investors[msg.sender];
        // Retrieves the investor data from the mapping
        investor.depositedAmount += amount;
        // Increases the deposited amount for the investor
        investor.tbillBalance += amount;
        // Increases the TBILL token balance for the investor
        investor.lastYieldUpdate = block.timestamp;
        // Updates the timestamp of the last yield update for the investor
        tbillContract.mint(msg.sender, amount);
        // Mints TBILL tokens to the investor
        if (investor.depositedAmount > 0) {
            investorAddresses.push(msg.sender);
            // Adds the investor's address to the array if it's not already present
        }
        emit Deposit(msg.sender, amount);
        // Emits a deposit event
    }

    function withdraw(uint256 amount) external nonReentrant {
        // Defines a function to allow investors to withdraw funds from the contract
        require(amount > 0, "Withdrawal amount must be greater than zero");
        // Requires the withdrawal amount to be greater than zero
        require(
            investors[msg.sender].tbillBalance >= amount,
            "Insufficient TBILL balance"
        );
        // Requires the investor to have sufficient TBILL token balance
        IERC20 cusdcContract = IERC20(cusdcToken);
        // Creates an instance of the IERC20 interface for the USDC/cUSD token
        investors[msg.sender].depositedAmount -= amount;
        // Decreases the deposited amount for the investor
        investors[msg.sender].tbillBalance -= amount;
        // Decreases the TBILL token balance for the investor
        investors[msg.sender].lastYieldUpdate = block.timestamp;
        // Updates the timestamp of the last yield update for the investor
        cusdcContract.safeTransfer(msg.sender, amount);
        // Transfers funds from the contract to the investor
        emit Withdraw(msg.sender, amount);
        // Emits a withdrawal event
    }

    function calculateAndUpdateYield(address investorAddress) internal {
        // Defines a function to calculate and update the yield for an investor
        Investor storage investor = investors[investorAddress];
        // Retrieves the investor data from the mapping
        uint256 elapsedTime = block.timestamp - investor.lastYieldUpdate;
        // Calculates the elapsed time since the last yield update
        if (elapsedTime >= maturityDuration) {
            // Checks if the maturity duration has been reached
            uint256 yieldEarned = (investor.depositedAmount * yieldRate) / 1e18;
            // Calculates the yield earned by the investor
            investor.yieldEarned += yieldEarned;
            // Increases the yield earned for the investor
            investor.lastYieldUpdate = block.timestamp;
            // Updates the timestamp of the last yield update for the investor
        }
    }

    function redeem(uint256 amount) external nonReentrant {
        // Defines a function to allow investors to redeem TBILL tokens
        require(amount > 0, "Redeem amount must be greater than zero");
        // Requires the redeem amount to be greater than zero
        require(
            investors[msg.sender].tbillBalance >= amount,
            "Insufficient TBILL balance"
        );
        // Requires the investor to have sufficient TBILL token balance
        calculateAndUpdateYield(msg.sender);
        // Calculates and updates the yield for the investor
        investors[msg.sender].depositedAmount += amount;
        // Increases the deposited amount for the investor
        investors[msg.sender].tbillBalance -= amount;
        // Decreases the TBILL token balance for the investor
        investors[msg.sender].lastYieldUpdate = block.timestamp;
        // Updates the timestamp of the last yield update for the investor
        TBILLToken tbillTokenContract = TBILLToken(tbillToken);
        // Creates an instance of the TBILLToken contract
        tbillTokenContract.transfer(msg.sender, amount);
        // Transfers TBILL tokens to the investor
        emit Redeem(msg.sender, amount);
        // Emits a redemption event
    }

    function updateYield() external {
        // Defines a function to update the yield for all investors
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            // Iterates through all investor addresses
            calculateAndUpdateYield(investorAddresses[i]);
            // Calculates and updates the yield for each investor
        }
        // emit YieldUpdated(totalYield);
        // Emits an event to log the updated yield (commented out for now)
    }
}
