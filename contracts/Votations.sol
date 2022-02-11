pragma solidity ^0.8.7;

contract Votations {
	mapping(address => bool) user;
	struct Votation {
		mapping(uint32 => address) candidates;
		uint32 rounds;
		uint32 actualRound;
		mapping(address => uint32) votes;
	}

	function register() public {
		require(user[msg.sender] != true, "User already register");
		user[msg.sender] = true;
	}

	function isRegisterUser(address _user) external view returns (bool) {
		return user[_user];
	}
}
