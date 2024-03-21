import { ethers } from "hardhat";

async function main() {

  const CUSDToken = await ethers.deployContract("CUSDToken"); 
  await CUSDToken.waitForDeployment();
  
  console.log(
    `CUSDToken contract deployed to ${CUSDToken.target}`
  );
  const TBILLToken = await ethers.deployContract("TBILLToken"); 
  await TBILLToken.waitForDeployment();
  
  console.log(
    `TBILLTokencontract deployed to ${TBILLToken.target}`
  );
  
  // const cusdcToken = "0x3a713416811728E7Ab977C6A3E3DC20F5aC9d1c7";
  // const billToken= "0x84A5962DcA4FC55f83b51ec0d0dA1a87D034a03b";

  // const TBillVault = await ethers.deployContract("TBillVault",[cusdcToken,billToken, 100]); 
  // await TBillVault.waitForDeployment();
  
  // console.log(
  //   `TBillVault contract deployed to ${TBillVault.target}`
  // );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
