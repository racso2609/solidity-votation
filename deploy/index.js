const CONTRACT_NAME = "Greeter";
// modify when needed
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // Upgradeable Proxy
  await deploy("Greeter", {
    from: deployer,
    proxy: {
      owner: deployer,
      execute: {
        init: {
          methodName: "initialize",
          args: ["First Greet"],
        },
      },
    },

    log: true,
  });
};

module.exports.tags = [CONTRACT_NAME];
