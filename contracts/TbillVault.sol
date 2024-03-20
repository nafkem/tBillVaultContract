// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IERC20.sol";
import "./ICErc20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TBILLVault is ReentrancyGuard {

    address public owner;

    // Import ERC20 interface
    IERC20 private cUsdcToken;
    IERC20 public cUsdcToken;
    IERC20 public tbillToken;

    bool private _notEntered; // Reentrancy guard

    uint256 public totalInvested;
    uint256 public totalYield;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public tbillTokenBalance;
    mapping(address => uint256) public yieldAccrued;
    mapping(address => uint256) public lastYieldCalculation;

    event Deposit(address indexed investor, uint256 amount);
    event Redemption(address indexed investor, uint256 amount);
    event YieldAccrued(address indexed investor, uint256 yield);
    event YieldDistributed(address indexed investor, uint256 yield);

    constructor(address _cUsdcToken, address _tbillToken) {
        owner = msg.sender;
        cUsdcToken = IERC20(_cUsdcToken);
        cUsdc = ICErc20(_cUsdcToken);
        tbillToken = IERC20(_tbillToken);
    }
    modifier nonReentrant() {
        // Ensure no reentrancy
        require(_notEntered, "Reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(cUsdcToken.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");

        // Ensure the token is not transferable
        require(!isTokenTransferable(cUsdcToken), "Token is transferable");

        // Transfer cUSDC from investor to the vault
        require(cUsdcToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Mint TBILL tokens to the investor
        balances[msg.sender] += amount;

        totalInvested += amount;

        emit Deposit(msg.sender, amount);
    }

    function redeem(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Ensure the token is not transferable
        require(!isTokenTransferable(cUsdcToken), "Token is transferable");

        // Burn cUSDC tokens from the investor
        require(cUsdc.redeemUnderlying(amount) == 0, "Redeem failed");

        // Transfer cUSDC to the investor
        require(cUsdcToken.transfer(msg.sender, amount), "Transfer failed");

        balances[msg.sender] -= amount;

        emit Redemption(msg.sender, amount);
    }

    function calculateYield() external {
        uint256 currentTime = block.timestamp;

        // Calculate yield for each investor since the last calculation
        for (uint256 i = 0; i < investorCount; i++) {
            address investor = investors[i];
            uint256 timeElapsed = currentTime - lastYieldCalculation[investor];
            uint256 investorBalance = balances[investor];
            uint256 yieldGenerated = calculateYieldForInvestor(investor, timeElapsed, investorBalance);
            
            yieldAccrued[investor] += yieldGenerated;
            lastYieldCalculation[investor] = currentTime;
            
            totalYield += yieldGenerated;
            
            emit YieldAccrued(investor, yieldGenerated);
        }
    }

    function distributeYield() external {
        for (uint256 i = 0; i < investorCount; i++) {
            address investor = investors[i];
            uint256 yieldToDistribute = yieldAccrued[investor];
            if (yieldToDistribute > 0) {
                uint256 investorProportion = (balances[investor] * 100) / totalInvested; // Calculate investor's proportion
                uint256 yieldForInvestor = (yieldToDistribute * investorProportion) / 100; // Distribute yield based on proportion
                
                require(tbillToken.transfer(investor, yieldForInvestor), "Transfer failed");
                
                yieldAccrued[investor] = 0;
                
                emit YieldDistributed(investor, yieldForInvestor);
            }
        }
    }
    function calculateYieldForInvestor(address investor, uint256 timeElapsed, uint256 balance) internal returns (uint256) {
    uint256 totalYieldGenerated = 0;

    // Simulated T-Bills data - maturity dates and interest rates
    uint256[] memory maturityDates = [timestamp1, timestamp2, timestamp3]; // Replace timestamps with actual maturity dates
    uint256[] memory interestRates = [5, 6, 7]; // Replace interest rates with actual rates (in percentage)

    for (uint256 i = 0; i < maturityDates.length; i++) {
        // Calculate time remaining until maturity
        uint256 remainingTime = maturityDates[i] > block.timestamp ? maturityDates[i] - block.timestamp : 0;

        // Calculate yield for this T-Bill
        uint256 yieldRate = (interestRates[i] * balance) / 100;
        uint256 yield = yieldRate * remainingTime;

        // Accumulate total yield generated
        totalYieldGenerated += yield;
    }

    return totalYieldGenerated;
}
}

