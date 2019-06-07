pragma solidity ^0.5.1;

import "./Auction.sol";
import "./Strategy.sol";

contract DutchAuction is Auction {
    Strategy strategy;
    uint creationBlock;
    uint winnerBlock;

    constructor (string memory _itemName, uint _reservePrice, uint _initialPrice, Strategy _strategy) public{
        description.seller = msg.sender;
        description.itemName = _itemName;
        description.state = State.GracePeriod;
        
        prices.reservePrice = _reservePrice;
        prices.initialPrice = _initialPrice;
        prices.actualPrice = _initialPrice;
        
        strategy = _strategy;
        
        creationBlock = block.number;
    }
    
    
    function activateAuction() public onlySeller{
        require(description.state == State.GracePeriod);
        
        //20 blocchi sono 5 minuti (+-)
        require(block.number - creationBlock > 2);


        description.state = State.Active;
        description.startBlock = block.number;
    }
    
    function validateAuction() internal{
        require(description.state == State.Active);
        description.state = State.Validating;
    }
    
    function finishAuction() public onlySeller{
        require(description.state == State.Validating);
        
        //faccio passare 6 blocchi così mi assicuro di stare sulla catena più lunga
        //questo perchè potrebbe capitare che due persone facciano bid nello stesso istante
        require(block.number - winnerBlock > 6);
        
        description.state = State.Finished;
    
        description.seller.transfer(description.winnerBid);
    }
    
    function getActualPrice() public returns(uint){
        computePrice();
        return prices.actualPrice;
    }
    
    function computePrice() internal{
        uint deltaBlocks = description.startBlock - block.number;
        uint tmp = strategy.getPrice(prices.actualPrice , -deltaBlocks);
        
        if(tmp <= prices.reservePrice)
            prices.actualPrice = prices.reservePrice;
        else
            prices.actualPrice = tmp;
    }
    
    
    function bid() public payable {
        require(description.state == State.Active);
        require(msg.value >= getActualPrice());
        
        description.winnerAddress = msg.sender;
        description.winnerBid = msg.value;
        
        winnerBlock = block.number;
        
        validateAuction();
    }
}
