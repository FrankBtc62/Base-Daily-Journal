// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DailyJournal {

    struct Entry {
        uint256 timestamp;
        string message;      // public ise dolu
        bytes32 messageHash; // private ise dolu
        bool revealed;
    }

    struct User {
        uint256 lastEntry;
        uint256 streak;
        uint256 total;
    }

    mapping(address => Entry[]) public entries;
    mapping(address => User) public users;

    uint256 constant COOLDOWN = 1 days;

    event NewEntry(address indexed user, uint256 index, bool isPrivate, uint256 streak);
    event Revealed(address indexed user, uint256 index, string message);

    // 🔓 Public entry
    function write(string calldata _message) external {
        _updateStreak();

        entries[msg.sender].push(Entry({
            timestamp: block.timestamp,
            message: _message,
            messageHash: 0,
            revealed: true
        }));

        emit NewEntry(msg.sender, entries[msg.sender].length - 1, false, users[msg.sender].streak);
    }

    // 🔒 Private entry (hash)
    function writePrivate(bytes32 _hash) external {
        _updateStreak();

        entries[msg.sender].push(Entry({
            timestamp: block.timestamp,
            message: "",
            messageHash: _hash,
            revealed: false
        }));

        emit NewEntry(msg.sender, entries[msg.sender].length - 1, true, users[msg.sender].streak);
    }

    // 🔓 Reveal private entry
    function reveal(uint256 _index, string calldata _message) external {
        Entry storage e = entries[msg.sender][_index];

        require(!e.revealed, "Already revealed");
        require(
            keccak256(abi.encodePacked(_message)) == e.messageHash,
            "Wrong message"
        );

        e.message = _message;
        e.revealed = true;

        emit Revealed(msg.sender, _index, _message);
    }

    function _updateStreak() internal {
        User storage u = users[msg.sender];

        if (u.lastEntry == 0) {
            u.streak = 1;
        } else if (block.timestamp >= u.lastEntry + COOLDOWN) {

            if (block.timestamp > u.lastEntry + (2 * COOLDOWN)) {
                u.streak = 1;
            } else {
                u.streak += 1;
            }

        } else {
            revert("Too early");
        }

        u.lastEntry = block.timestamp;
        u.total += 1;
    }

    function getEntries(address _user) external view returns (Entry[] memory) {
        return entries[_user];
    }
}
