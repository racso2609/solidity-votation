const CONTRACT_NAME = "Votations";
// modify when needed
module.exports = async ({ getNamedAccounts, deployments }) => {
	const { deploy } = deployments;
	const { deployer } = await getNamedAccounts();

	// Upgradeable Proxy
	await deploy("Votations", {
		from: deployer,
		proxy: {
			owner: deployer,
		},

		log: true,
	});
};

module.exports.tags = [CONTRACT_NAME];
