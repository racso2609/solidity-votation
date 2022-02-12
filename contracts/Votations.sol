pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Votations is Ownable {
	mapping(address => bool) user;
	mapping(uint256 => mapping(uint32 => address)) candidates;
	mapping(uint256 => mapping(address => uint32)) votes;

	struct Votation {
		string name;
		uint32 rounds;
		uint32 actualRounds;
	}

	uint256 votationsQuantity;
	mapping(uint256 => Votation) public votations;

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

	event CreateVotation(uint256 indexed votationId, string indexed name);

	function createVotations(
		string memory _name,
		address[] memory _candidates,
		uint32 _rounds
	) external onlyOwner returns (uint256) {
		Votation memory newVotation;
		newVotation.name = _name;
		newVotation.rounds = _rounds;
		for (uint32 i = 0; i < _candidates.length; i++) {
			candidates[votationsQuantity][i] = _candidates[i];
		}
		votationsQuantity++;
		votations[votationsQuantity - 1] = newVotation;
		emit CreateVotation(votationsQuantity - 1, _name);
		return votationsQuantity - 1;
	}
}
