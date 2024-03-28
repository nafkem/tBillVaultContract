import { ethers } from "hardhat";
import { tBillTokenSol } from "../typechain-types/contracts";

async function main() {

  // const CUSDToken = await ethers.deployContract("CUSDToken"); 
  // await CUSDToken.waitForDeployment();
  
  // console.log(
  //   `CUSDToken contract deployed to ${CUSDToken.target}`
  // );
  // const TBILLToken = await ethers.deployContract("TBILLToken"); 
  // await TBILLToken.waitForDeployment();
  
  // console.log(
  //   `TBILLTokencontract deployed to ${TBILLToken.target}`
  // );
  
  const cusdcToken = "0x85271cb4A12a0BB18c82c5BC7d7F8752B68b79cE"
  const tbillToken = "0x2eBB810dA7704b1f9A4eA95f0ffebb661418fB7F"

  //TBillVault contract deployed to 0xb6DE8918C7174AeBB7F837bB0723F6B74755Ba16

  const TBillVault = await ethers.deployContract("TBillVault",[cusdcToken,tbillToken]); 
  await TBillVault.waitForDeployment();
  
  console.log(
    `TBillVault contract deployed to ${TBillVault.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
