pragma solidity ^ 0.5.1;

//TEMPLATE METHOD PATTERN
contract Auction {

    modifier onlySeller() {
        require(msg.sender == description.seller);
        _;
    }

    struct Description {
        address payable seller;
        string itemName;
        uint startBlock;
        address winnerAddress;
        uint winnerBid;
    }

    Description public description;


    event auctionStarted();
    event auctionFinished(address winnerAddress, uint winnerBid, uint surplusFounds);


    function activateAuction() public;
}