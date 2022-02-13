const { expect } = require("chai");
const { fixture } = deployments;
const { printGas } = require("../utils/transactions.js");
// const { solidity } = require("ethereum-waffle");

describe("Votation", () => {
	beforeEach(async () => {
		({ deployer, user, userNotRegister } = await getNamedAccounts());

		deployerSigner = await ethers.provider.getSigner(deployer);
		userSigner = await ethers.provider.getSigner(user);
		userNotRegisterSigner = await ethers.provider.getSigner(userNotRegister);

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
		it("event emmited", async () => {
			await expect(votation.connect(userSigner).register())
				.to.emit(votation, "Register")
				.withArgs(user);
		});
	});
	describe("create Votations", () => {
		beforeEach(async () => {
			// await votation.connect(userSigner).register();
			// candidates =
			[addr1, addr2, addr3, addr4, addr5, addr6] = await ethers.getSigners();
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
				votation.connect(userSigner).createVotations("President", candidates, 0)
			).to.be.revertedWith("Ownable: caller is not the owner");
		});
		it("fail creating more than 5 candidates", async () => {
			expect(
				votation
					.connect(deployerSigner)
					.createVotations("President", [...candidates, addr6.address], 0)
			).to.be.revertedWith("Max 5 candidates per votation");
		});

		it("creating", async () => {
			const tx = await votation
				.connect(deployerSigner)
				.createVotations("President", candidates, 0);
			await printGas(tx);
			await tx.wait();
			const votationId = Number(tx.value);
			const newVotation = await votation.votations(votationId);

			expect(newVotation.name).to.be.equal("President");
			expect(newVotation.rounds).to.be.equal(0);
			expect(newVotation.actualRound).to.be.equal(0);
		});
		it("event emmited", async () => {
			await expect(
				votation
					.connect(deployerSigner)
					.createVotations("President", candidates, 0)
			)
				.to.emit(votation, "CreateVotation")
				.withArgs(0, "President");
		});
	});
	describe("Vote", () => {
		beforeEach(async () => {
			await votation.connect(userSigner).register();
			[addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();
			candidates = [
				addr1.address,
				addr2.address,
				addr3.address,
				addr4.address,
				addr5.address,
			];
			await votation.connect(addr1).register();
			await votation
				.connect(deployerSigner)
				.createVotations("President", candidates, 0);
			eightDays = 8 * 24 * 60 * 60;
		});

		it("fail candidate does not exist ", async () => {
			await expect(
				votation.connect(userSigner).makeVote(0, 6)
			).to.be.revertedWith("Candidate does not exist!");
		});
		it("fail votation does not exist ", async () => {
			await expect(
				votation.connect(userSigner).makeVote(1, 1)
			).to.be.revertedWith("Votation finished");
		});
		it("fail user not register ", async () => {
			await expect(
				votation.connect(userNotRegisterSigner).makeVote(0, 6)
			).to.be.revertedWith("You are not register");
		});
		it("vote ", async () => {
			const tx = await votation.connect(userSigner).makeVote(0, 1);
			await tx.wait();
			const vote = await votation.votes(0, 0, user);
			expect(vote).to.be.equal(1);
		});
		it("fail voting twice ", async () => {
			await votation.connect(userSigner).makeVote(0, 1);
			await expect(
				votation.connect(userSigner).makeVote(0, 1)
			).to.be.revertedWith("You only can vote once!");
		});
		it("fail voting for yourselve ", async () => {
			await expect(votation.connect(addr1).makeVote(0, 1)).to.be.revertedWith(
				"You can not vote for yourselve!"
			);
		});

		it("fail votation finished ", async () => {
			await ethers.provider.send("evm_increaseTime", [eightDays]);
			await ethers.provider.send("evm_mine");
			await expect(votation.connect(addr1).makeVote(0, 1)).to.be.revertedWith(
				"Votation finished"
			);
		});
		it("event emmited", async () => {
			await expect(votation.connect(userSigner).makeVote(0, 1))
				.to.emit(votation, "Vote")
				.withArgs(0, 1);
		});
	});
});
