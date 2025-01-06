// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract DecentralizedIdentity is Ownable {
    using Counters for Counters.Counter;
    using ECDSA for bytes32;

    // Struct to hold user identity information
    struct Identity {
        uint256 id;
        string name;
        string email;
        bool isVerified;
        address verifier;
    }

    // Mapping from user address to their identity
    mapping(address => Identity) private identities;
    // Counter for identity IDs
    Counters.Counter private identityCounter;

    // Event emitted when an identity is created
    event IdentityCreated(address indexed user, uint256 id, string name, string email);
    // Event emitted when an identity is verified
    event IdentityVerified(address indexed user, address indexed verifier);
    // Event emitted when an identity is revoked
    event IdentityRevoked(address indexed user);

    // Modifier to check if the identity exists
    modifier identityExists(address user) {
        require(identities[user].id != 0, "Identity does not exist");
        _;
    }

    // Function to create a new identity
    function createIdentity(string memory name, string memory email) external {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(email).length > 0, "Email cannot be empty");

        identityCounter.increment();
        uint256 newId = identityCounter.current();

        identities[msg.sender] = Identity(newId, name, email, false, address(0));
        emit IdentityCreated(msg.sender, newId, name, email);
    }

    // Function to verify an identity
    function verifyIdentity(address user) external onlyOwner identityExists(user) {
        identities[user].isVerified = true;
        identities[user].verifier = msg.sender;
        emit IdentityVerified(user, msg.sender);
    }

    // Function to revoke an identity
    function revokeIdentity(address user) external onlyOwner identityExists(user) {
        delete identities[user];
        emit IdentityRevoked(user);
    }

    // Function to get identity details
    function getIdentity(address user) external view identityExists(user) returns (Identity memory) {
        return identities[user];
    }

    // Function to check if an identity is verified
    function isIdentityVerified(address user) external view identityExists(user) returns (bool) {
        return identities[user].isVerified;
    }

    // Function to get the verifier of an identity
    function getVerifier(address user) external view identityExists(user) returns (address) {
        return identities[user].verifier;
    }
}
