pragma solidity ^0.5.1;

import "./Auction.sol";

contract DutchAuction is Auction {
    uint initialPrice;
    uint reservePrice;

    constructor (uint _initialPrice, uint _reservePrice, uint _startblock) public {
        initialPrice = _initialPrice;
        reservePrice = _reservePrice;
        startBlock = _startblock;
        seller = msg.sender;
    }
}
