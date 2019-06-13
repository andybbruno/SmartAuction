pragma solidity ^ 0.5.1;

contract Auction {

    struct Description {
        address payable seller;
        string itemName;
        uint startBlock;
        address winnerAddress;
        uint winnerBid;
    }

    Description public description;


    modifier onlySeller() {
        require(msg.sender == description.seller, "Only the seller can run this function");
        _;
    }

    event auctionStarted();
    event auctionFinished(address winnerAddress, uint winnerBid, uint surplusFounds);


    function activateAuction() public;
    function finalize() public;
}

