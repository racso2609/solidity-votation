pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Votations is Ownable {
	mapping(address => bool) user;
	/**
	 * @dev get canditates by votationId and candidate index .
   candidate index start on 1 on this way we can heck if you already vote if you vote != 0
	 */
	mapping(uint256 => mapping(uint32 => address)) public candidates;
	/**
	 * @dev get votes by votationId and userAddress.
	 */
	mapping(uint256 => mapping(address => uint32)) public votes;

	struct Votation {
		string name;
		// uint32 rounds;
		// uint32 actualRounds;
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
    event Register(address indexed user);

	function register() public {
		require(user[msg.sender] != true, "User already register");
		user[msg.sender] = true;
    emit Register(msg.sender);
	}

	function isRegisterUser(address _user) external view returns (bool) {
		return user[_user];
	}

	event CreateVotation(uint256 indexed votationId, string indexed name);

	/**
     * @dev create votation round with a {_name} candidates {_candidates}.
     *
     . {_name} should be a string and {_candidate} array of address this address dont need to be register but should register if they want vote
     *
     */

	function createVotations(string memory _name, address[] memory _candidates)
		external
		// uint32 _rounds
		onlyOwner
		returns (uint256)
	{
    require(_candidates.length < 6,"Max 5 candidates per votation");
		Votation memory newVotation;
		newVotation.name = _name;
		// newVotation.rounds = _rounds;
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

	/**
     * @dev vote for a candidate only if you are register and the votation is not ended.
     you should provide a valie {_votationId} {_candidate}
     *
     *
     */

	function makeVote(uint256 _votationId, uint32 _candidate)
		external
		onlyRegister
		votationNotFinished(_votationId)
	{
		require(_candidate > 0, "Candidate does not exist!");
		// require(votations[_votationId].name , "Votation does not exist!");
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
		emit Vote(_votationId, _candidate);
	}
}
