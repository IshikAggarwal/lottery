// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title DecentralizedLottery
 * @dev A transparent and fair blockchain-based lottery system
 */
contract Project {
    address public owner;
    address[] public players;
    uint256 public lotteryId;
    uint256 public ticketPrice;
    
    mapping(uint256 => address) public lotteryHistory;
    
    event PlayerEntered(address indexed player, uint256 amount);
    event WinnerSelected(address indexed winner, uint256 amount, uint256 lotteryId);
    event TicketPriceUpdated(uint256 newPrice);
    
    constructor(uint256 _ticketPrice) {
        owner = msg.sender;
        lotteryId = 1;
        ticketPrice = _ticketPrice;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    /**
     * @dev Allows a player to enter the lottery by sending ETH
     */
    function enterLottery() public payable {
        require(msg.value == ticketPrice, "Incorrect ticket price");
        players.push(msg.sender);
        emit PlayerEntered(msg.sender, msg.value);
    }
    
    /**
     * @dev Generates a pseudo-random number for winner selection
     * Note: This is not truly random and should not be used in production
     */
    function getRandomNumber() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            players.length,
            msg.sender
        )));
    }
    
    /**
     * @dev Selects a winner and transfers the prize pool
     */
    function pickWinner() public onlyOwner {
        require(players.length > 0, "No players in the lottery");
        
        uint256 index = getRandomNumber() % players.length;
        address winner = players[index];
        uint256 prizePool = address(this).balance;
        
        lotteryHistory[lotteryId] = winner;
        
        emit WinnerSelected(winner, prizePool, lotteryId);
        
        lotteryId++;
        
        // Reset the lottery
        delete players;
        
        // Transfer prize to winner
        payable(winner).transfer(prizePool);
    }
    
    /**
     * @dev Updates the ticket price for future lotteries
     */
    function updateTicketPrice(uint256 _newPrice) public onlyOwner {
        require(_newPrice > 0, "Price must be greater than 0");
        ticketPrice = _newPrice;
        emit TicketPriceUpdated(_newPrice);
    }
    
    /**
     * @dev Returns the list of current players
     */
    function getPlayers() public view returns (address[] memory) {
        return players;
    }
    
    /**
     * @dev Returns the current prize pool
     */
    function getPrizePool() public view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Returns the winner of a specific lottery ID
     */
    function getWinnerByLottery(uint256 _lotteryId) public view returns (address) {
        return lotteryHistory[_lotteryId];
    }
    
    /**
     * @dev Returns the number of players in current lottery
     */
    function getPlayerCount() public view returns (uint256) {
        return players.length;
    }
}
