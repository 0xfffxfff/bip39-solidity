// const hre = require("hardhat");

module.exports = async ({ deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const renderLibrary = await deploy("Render", { from: deployer, log: true });
  await deploy("SeedPoems", {
    args: [],
    from: deployer,
    gasLimit: 18_000_000,
    log: true,
    // nonce: 0,
    // gasPrice: 60_000_000_000 // 60
    libraries: {
      Render: renderLibrary.address,
    },
  });
};

module.exports.tags = ["SeedPoems", "Render"];
