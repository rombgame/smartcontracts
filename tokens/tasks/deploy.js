const { getProxyAddress } = require("../helpers/proxymap");

task("deploy", "Deploys entire project").setAction(async (taskArgs, hre) => {
  const isForceCreateNewContracts = false;
  const isVerify = true;

  const accounts = await hre.ethers.getSigners();
  if (accounts.length === 0) {
    console.log("Must specify signers");
    return;
  }

  await hre.run("compile");

  await hre.run("deployVerify", {
    contractName: "ROMB",
    constructorArguments: [],
    forceCreate: isForceCreateNewContracts,
    verify: isVerify,
  });

  await hre.run("deployVerify", {
    contractName: "ROMG",
    constructorArguments: [],
    forceCreate: isForceCreateNewContracts,
    verify: isVerify,
  });

  await hre.run("deployVerify", {
    contractName: "VestingWallet",
    constructorArguments: [],
    forceCreate: isForceCreateNewContracts,
    verify: isVerify,
  });

  const vesting = await ethers.getContractAt(
    "VestingWallet",
    getProxyAddress("VestingWallet")
  );
  let t = await vesting.setToken(getProxyAddress("ROMB"));
  await t.wait(1);
  console.log("\nSet token in VestingWallet");

  console.log("\n==== Project Deploy Complete ====");
});

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
};
