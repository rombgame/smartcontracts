const { types } = require("hardhat/config")

task("safeVerify", "Verifies contract on Etherscan safely")
  .addParam("address", "Smartcontract's address", "0x", types.string)
  .addParam("constructorArguments", "Smartcontract's constructor arguments", [], types.json)
  .setAction(async (taskArgs, hre) => {
    if (hre.network.config.chainId === 31337 || !hre.config.etherscan.apiKey) {
      console.log("Skipping verification")
      return;
    }

    // await contract.deployTransaction.wait(5);

    try {
      console.log("Verifying ...");

      await hre.run("verify:verify", {
        address: taskArgs.address,
        constructorArguments: taskArgs.constructorArguments,
      });
    } catch (error) {
      if (error.message.includes("Contract source code already verified")) return;

      console.log(error);
      process.exitCode = 1;
    }
  });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
};