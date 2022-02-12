const { expect } = require("chai");
const { fixture } = deployments;
const { printGas } = require("../utils/transactions.js");
// const { solidity } = require("ethereum-waffle");


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
	describe("User", () => {
		it("register user", async () => {
			expect(await votation.isRegisterUser(user)).to.be.equal(false);
			await votation.connect(userSigner).register();
			expect(await votation.isRegisterUser(user)).to.be.equal(true);
		});
	});
	describe("Votations", () => {
		beforeEach(async () => {
			// await votation.connect(userSigner).register();
			// candidates =
			[addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();
			candidates = [
				addr1.address,
				addr2.address,
				addr3.address,
				addr4.address,
				addr5.address,
			];
		});

		it("error creating votation, user not owner", async () => {
			await expect(
				votation.connect(userSigner).createVotations(
					"President",
					candidates,
					1
				)
			).to.be.revertedWith("Ownable: caller is not the owner");
		});

		it("creating", async () => {
			const tx = await votation.connect(deployerSigner).createVotations(
				"President",
				candidates,
				1
			);
			await printGas(tx);
			await tx.wait();
			const votationId = Number(tx.value);
			const newVotation = await votation.votations(votationId);

			expect(newVotation.name).to.be.equal("President");
			expect(newVotation.rounds).to.be.equal(1);
			expect(newVotation.actualRounds).to.be.equal(0);
		});
		it("event emmited", async () => {
			await expect(votation.connect(deployerSigner).createVotations("President",candidates, 1))
				.to.emit(votation, "CreateVotation")
				.withArgs(0,"President");
		});
	});
});
