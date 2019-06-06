pragma solidity ^0.5.1;

import "./DutchAuction.sol";
import "./Auction.sol";

contract AuctionHouse {
    Auction[] public auctions;
    
    function newAuction(address seller, int startBlock) public {
        Auction auction = new Auction();
        auctions.push(auction);
    }
    
}
