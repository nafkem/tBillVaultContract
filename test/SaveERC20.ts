// import "foundry.sol";
// import "ds-test/test.sol";
// import "./TBillVault.sol";
// import "./ERC20Token.sol";
// import "./tBillToken.sol";

// contract TBillVaultTest is DSTest {
//     ERC20Token public cusdcToken;
//     TBILLToken public tbillToken;
//     TBillVault public tbillVault;

//     function setUp() public {
//         cusdcToken = new ERC20Token();
//         tbillToken = new TBILLToken();
//         tbillVault = new TBillVault(address(cusdcToken), address(tbillToken), 10);
//     }

//     function testDepositAndWithdraw() public {
//         uint256 amount = 100;
//         cusdcToken.mint(address(this), amount);

//         // Approve the TBillVault contract to spend cusdcToken
//         cusdcToken.approve(address(tbillVault), amount);

//         // Deposit cusdcToken to TBillVault
//         tbillVault.deposit(amount);

//         // Assert the deposited amount is correct
//         assertEq(tbillToken.balanceOf(address(this)), amount);

//         // Withdraw cusdcToken from TBillVault
//         tbillVault.withdraw(amount);

//         // Assert the withdrawn amount is correct
//         assertEq(cusdcToken.balanceOf(address(this)), amount);
//     }

//     function testUpdateYield() public {
//         uint256 amount = 100;
//         cusdcToken.mint(address(this), amount);

//         // Approve the TBillVault contract to spend cusdcToken
//         cusdcToken.approve(address(tbillVault), amount);

//         // Deposit cusdcToken to TBillVault
//         tbillVault.deposit(amount);

//         // Simulate the passage of time
//         uint256 elapsedTime = 365 days;
//         tbillVault.updateYield{gas: gasleft()}();

//         // Calculate the expected yield earned
//         uint256 expectedYield = (amount * 10 * elapsedTime) / (365 days * 100);

//         // Assert the yield earned is correct
//         assertEq(tbillToken.balanceOf(address(this)), amount + expectedYield);
//     }

//     function testRedeem() public {
//         uint256 amount = 100;
//         cusdcToken.mint(address(this), amount);

//         // Approve the TBillVault contract to spend cusdcToken
//         cusdcToken.approve(address(tbillVault), amount);

//         // Deposit cusdcToken to TBillVault
//         tbillVault.deposit(amount);

//         // Redeem cusdcToken from TBillVault
//         tbillVault.redeem(amount);

//         // Assert the redeemed amount is correct
//         assertEq(cusdcToken.balanceOf(address(this)), amount);
//     }

//     function testAccessControl() public {
//         // Test that only the owner can call certain functions
//         address nonOwner = address(0x1);

//         // Try to withdraw without being the owner
//         try tbillVault.withdraw(100) {
//             assert(false, "Withdrawal by non-owner should revert");
//         } catch Error(string memory) {}

//         // Try to redeem without being the owner
//         try tbillVault.redeem(100) {
//             assert(false, "Redeem by non-owner should revert");
//         } catch Error(string memory) {}
//     }
// }
