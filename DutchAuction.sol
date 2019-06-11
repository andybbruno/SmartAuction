pragma solidity ^ 0.5.1;

import "./Auction.sol";
import "./Strategy.sol";

contract DutchAuction is Auction {
    Strategy strategy;

    uint creationBlock;
    uint winnerBlock;
    uint reservePrice;
    uint initialPrice;
    uint actualPrice;

    enum State {
        GracePeriod,
        Active,
        Validating,
        Finished
    }
    State state;


    constructor(
        string memory _itemName, 
        uint _reservePrice, 
        uint _initialPrice, 
        Strategy _strategy
    ) public {
        description.seller = msg.sender;
        description.itemName = _itemName;
        state = State.GracePeriod;

        reservePrice = _reservePrice;
        initialPrice = _initialPrice;
        actualPrice = _initialPrice;

        strategy = _strategy;

        creationBlock = block.number;
    }



    function activateAuction() public onlySeller {
        require(state == State.GracePeriod);

        //20 blocchi sono 5 minuti (+-)
        require(block.number - creationBlock > 2);


        state = State.Active;
        description.startBlock = block.number;

        emit auctionStarted();
    }

    function validateAuction() internal {
        require(state == State.Active);
        state = State.Validating;
    }

    function finalize() public onlySeller {
        require(state == State.Validating);

        //faccio passare 6 blocchi così mi assicuro di stare sulla catena più lunga
        //questo perchè potrebbe capitare che due persone facciano bid nello stesso istante
        require(block.number - winnerBlock > 6);

        state = State.Finished;
        emit auctionFinished(description.winnerAddress, description.winnerBid);

        description.seller.transfer(description.winnerBid);

    }

    function getActualPrice() public returns(uint) {
        computePrice();
        return actualPrice;
    }

    function computePrice() internal {
        uint deltaBlocks = description.startBlock - block.number;
        uint tmp = strategy.getPrice(actualPrice, -deltaBlocks);

        if (tmp <= reservePrice)
            actualPrice = reservePrice;
        else
            actualPrice = tmp;
    }


    function bid() public payable {
        require(state == State.Active);
        require(msg.value >= getActualPrice());

        description.winnerAddress = msg.sender;
        description.winnerBid = msg.value;

        winnerBlock = block.number;

        validateAuction();
    }
}