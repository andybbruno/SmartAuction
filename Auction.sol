pragma solidity ^0.5.1;

//TEMPLATE METHOD PATTERN
contract Auction{
    
    modifier onlySeller(){
        require(msg.sender == description.seller);
        _;
    }
    
    enum State {GracePeriod, Active, Validating, Finished}
    
    struct Description {
        address payable seller;
        string itemName;
        State state;
        uint startBlock;
        address winnerAddress;
        uint winnerBid;
    }
    
    Description public description;
    
    struct Prices {
        uint reservePrice;
        uint initialPrice;
        uint actualPrice;
    }
    
    Prices prices;
    
    
    mapping(address => uint) bids;

}