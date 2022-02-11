pragma solidity ^0.8.7;

contract Votations {
	mapping(address => bool) user;
	mapping(uint256 => mapping(uint32 => address)) candidates;
	mapping(uint256 => mapping(address => uint32)) votes;

	//TODO: Investigato how to return strings
	struct Votation {
		// string name;
		uint32 rounds;
		uint32 actualRounds;
	}

	uint256 votationsQuantity;
	mapping(uint256 => Votation) votations;

	function register() public {
		require(user[msg.sender] != true, "User already register");
		user[msg.sender] = true;
	}

	function isRegisterUser(address _user) external view returns (bool) {
		return user[_user];
	}

	modifier onlyRegister() {
		require(user[msg.sender] == true, "You are not register");
		_;
	}

	event VotationEvent(uint256 indexed votationId);

	function createVotations(
		// string memory _name,
		address[] memory _candidates,
		uint32 _rounds
	) external onlyRegister returns (uint256) {
		Votation memory newVotation;
		// newVotation.name = _name;
		newVotation.rounds = _rounds;
		for (uint32 i = 0; i < _candidates.length; i++) {
			candidates[votationsQuantity][i] = _candidates[i];
		}
		votationsQuantity++;
		votations[votationsQuantity - 1] = newVotation;
		emit VotationEvent(votationsQuantity - 1);
		return votationsQuantity - 1;
	}

	function getVotation(uint256 _votationId)
		external
		view
		returns (
			// memory string name,
			uint32,
			uint32
		)
	{
		require(votationsQuantity > _votationId, "votation does not exits");

		Votation memory votation = votations[_votationId];
		uint32 rounds = votation.rounds;
		uint32 actualRounds = votation.actualRounds;
		return (rounds, actualRounds);
	}
}
