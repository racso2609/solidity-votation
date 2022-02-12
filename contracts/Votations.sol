pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Votations is Ownable {
	mapping(address => bool) user;
	/**
	 * @dev get canditates by votationId and candidate index.
	 */
	mapping(uint256 => mapping(uint32 => address)) public candidates;
	/**
	 * @dev get votes by votationId and userAddress.
	 */
	mapping(uint256 => mapping(address => uint32)) public votes;

	struct Votation {
		string name;
		uint32 rounds;
		uint32 actualRounds;
		uint256 startTime;
	}
	/**
	 * @dev {votationsQuantity} a register of all votations done and is used for calculate the votationId.
	 */

	uint256 votationsQuantity;
	mapping(uint256 => Votation) public votations;

	/**
     * @dev Register user using {msg.sender}.
     *
     . the default value of {user} is false if you are register the value is true
     *
     */

	function register() public {
		require(user[msg.sender] != true, "User already register");
		user[msg.sender] = true;
	}

	function isRegisterUser(address _user) external view returns (bool) {
		return user[_user];
	}

	event CreateVotation(uint256 indexed votationId, string indexed name);

	function createVotations(
		string memory _name,
		address[] memory _candidates,
		uint32 _rounds
	) external onlyOwner returns (uint256) {
		Votation memory newVotation;
		newVotation.name = _name;
		newVotation.rounds = _rounds;
		newVotation.startTime = block.timestamp;
		for (uint32 i = 0; i < _candidates.length; i++) {
			candidates[votationsQuantity][i + 1] = _candidates[i];
		}
		votationsQuantity++;
		votations[votationsQuantity - 1] = newVotation;
		emit CreateVotation(votationsQuantity - 1, _name);
		return votationsQuantity - 1;
	}

	event Vote(uint256 indexed votationId, uint32 indexed candidate);

	modifier onlyRegister() {
		require(user[msg.sender] == true, "You are not register");
		_;
	}
	modifier votationNotFinished(uint256 _votationId) {
		require(
			block.timestamp < votations[_votationId].startTime + 7 days,
			"Votation finished"
		);
		_;
	}

	function makeVote(uint256 _votationId, uint32 _candidate)
		external
		onlyRegister
		votationNotFinished(_votationId)
	{
		require(_candidate > 0, "Candidate does not exist!");
		require(
			candidates[_votationId][_candidate] != address(0x0),
			"Candidate does not exist!"
		);
		require(
			candidates[_votationId][_candidate] != msg.sender,
			"You can not vote for yourselve!"
		);

		require(votes[_votationId][msg.sender] == 0, "You only can vote once!");
		votes[_votationId][msg.sender] = _candidate;
    emit Vote(_votationId,_candidate);

	}
}
