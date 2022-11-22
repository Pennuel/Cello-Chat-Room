// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract ClassGroupChat {
    uint internal messageLength = 0;
    struct MessageRating {
        uint total_raters;
        uint total_rate;
    }

    struct Message {
        address payable owner;
        string name;
        string message;
        uint date;
        uint upvotes;
        MessageRating rating;
    }

    mapping(uint => Message) private messages;

    mapping(uint => mapping(address => bool)) public rated;
    mapping(uint => mapping(address => bool)) public upvoted;

    modifier notOwner(uint index) {
        require(messages[index].owner != msg.sender, "You are the owner");
        _;
    }


    /**
     * @dev allow users to add a message to the platform
     * @notice content of message can't be empty
     */
    function createMessage(string calldata _name, string calldata _message)
        public
    {
        require(bytes(_name).length > 0, "Empty name");
        require(bytes(_message).length > 0, "Empty message");
        messages[messageLength] = Message(
            payable(msg.sender),
            _name,
            _message,
            block.timestamp,
            0,
            MessageRating(0, 0)
        );
        messageLength++;
    }

    /**
     * @dev allow users to retrieve a message
     */
    function viewMessages(uint _index)
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            uint,
            MessageRating memory
        )
    {
        Message storage currentMessage = messages[_index];
        return (
            currentMessage.owner,
            currentMessage.name,
            currentMessage.message,
            currentMessage.date,
            currentMessage.rating
        );
    }

    
    function editMessages(uint _index, string calldata message) public {
        Message storage currentMessage = messages[_index];
        require(msg.sender == currentMessage.owner);
        currentMessage.message = message;
        currentMessage.date = block.timestamp;
    }

    /**
     * @dev allow users to write a rating for a message
     * @notice Users can only rate once and the rating has to be from 1 to 5
     */
    function writeRating(uint _index, uint rate) public notOwner(_index){
        require(
            !rated[_index][msg.sender],
            "You have already rated this message"
        );
        require(rate > 0 && rate <= 5, "Rate can only be 1 up to 5");
        Message storage currentMessage = messages[_index];
        rated[_index][msg.sender] = true;
        currentMessage.rating.total_rate += rate;
        currentMessage.rating.total_raters += 1;
    }

    function upvote(uint _index) public notOwner(_index){
        require(
            !upvoted[_index][msg.sender],
            "You have already upvoted"
        );
        Message storage currentMessage = messages[_index];
        upvoted[_index][msg.sender] = true;
        currentMessage.upvotes++;
    }

    /**
        @dev allow users to delete their message
     */
    // function deleteMessage(uint _index) public {
    //     require(messages[_index].owner == msg.sender);
    //     delete(messages[_index]);
    // }

    /// @return messageLength the current number of messages
    function getMessageLength() public view returns (uint) {
        return (messageLength);
    }
}
