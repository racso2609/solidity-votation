const { expect } = require("chai");
const { fixture } = deployments;

describe("Votation", () => {
	beforeEach(async () => {
		({ deployer, user } = await getNamedAccounts());

		deployerSigner = await ethers.provider.getSigner(deployer);
		userSigner = await ethers.provider.getSigner(user);

		// Deploy contracts
		await fixture(["Votations"]);
		Votation = await ethers.getContractFactory("Votations");
		votation = await Votation.deploy();
	});

	it("register user", async () => {
		expect(await votation.isRegisterUser(user)).to.be.equal(false);
		await votation.connect(userSigner).register();
		expect(await votation.isRegisterUser(user)).to.be.equal(true);
	});
});
