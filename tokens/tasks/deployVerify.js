const { types } = require("hardhat/config");
const { setProxyAddress, getProxyAddress } = require("../helpers/proxymap");

task("deployVerify", "Deploys and verifies a single contract")
  .addParam("contractName", "Smartcontract's name", "0x", types.string)
  .addParam(
    "constructorArguments",
    "Smartcontract's constructor arguments",
    [],
    types.json
  )
  .addParam(
    "forceCreate",
    "Creates new proxy and implementation instead of upgrading",
    false,
    types.boolean
  )
  .addParam("verify", "Verifies on Etherscan", false, types.boolean)
  .addParam("proxyType", "Proxy type", "uups", types.string)
  .setAction(async (taskArgs, hre) => {
    if (taskArgs.proxyType === "none") {
      console.log("\n==== " + taskArgs.contractName + " ====");
      console.log("Deploying...");

      const Contract = await ethers.getContractFactory(taskArgs.contractName);
      const contract = await Contract.deploy(...taskArgs.constructorArguments);
      await contract.deployed();
      console.log(
        "Deployed " + taskArgs.contractName + " @ " + contract.address
      );

      setProxyAddress(taskArgs.contractName, contract.address);

      if (!taskArgs.verify) return;

      console.log("Waiting before verification...");
      await sleep(60000 * 2);

      await hre.run("safeVerify", {
        address: contract.address,
        constructorArguments: taskArgs.constructorArguments,
      });

      return;
    }

    let proxyAddress = getProxyAddress(taskArgs.contractName);
    const isUpgrade =
      proxyAddress !== "" && !taskArgs.forceCreate ? true : false;

    console.log("\n==== " + taskArgs.contractName + " ====");
    console.log(isUpgrade ? "Upgrading..." : "Deploying...");

    const factory = await hre.ethers.getContractFactory(taskArgs.contractName);

    const proxy = !isUpgrade
      ? await hre.upgrades.deployProxy(factory, [], { kind: "uups" })
      : await hre.upgrades.upgradeProxy(proxyAddress, factory, {
          kind: "uups",
        });
    2;
    await proxy.deployed();

    setProxyAddress(taskArgs.contractName, proxy.address);

    const implementation = await hre.upgrades.erc1967.getImplementationAddress(
      proxy.address
    );

    console.log(
      isUpgrade
        ? "Kept proxy @ " + proxy.address
        : "Deployed proxy @ " + proxy.address
    );
    console.log("Deployed implementation @ " + implementation);

    if (!taskArgs.verify) return;

    await hre.run("safeVerify", {
      address: implementation,
      constructorArguments: taskArgs.constructorArguments,
    });
  });

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
};
