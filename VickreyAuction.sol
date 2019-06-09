pragma solidity ^ 0.5.1;

import "./Auction.sol";

contract VickreyAuction is Auction {

    enum Phase {
        GracePeriod,
        Commitment,
        Withdrawal,
        Opening,
        Finished
    }
    Phase phase;

    uint creationBlock;
    uint reservePrice;
    uint min_deposit;

    struct Bid {
        uint value;
        bytes32 hash;
        uint deposit;
    }
    mapping(address => Bid) bids_reg;



    constructor(
        string memory _itemName,
        uint _reservePrice,
        uint _min_deposit,
        uint commitment_len,
        uint withdrawal_len,
        uint opening_len
    ) public {
        require(_reservePrice > 0);
        require(_min_deposit > 0);
        require(commitment_len > 0);
        require(withdrawal_len > 0);
        require(opening_len > 0);

        description.seller = msg.sender;
        description.itemName = _itemName;
        phase = Phase.GracePeriod;

        reservePrice = _reservePrice;
        min_deposit = _min_deposit;
        creationBlock = block.number;
    }


    function activateAuction() public onlySeller {
        require(phase == Phase.GracePeriod);

        //20 blocchi sono 5 minuti (+-)
        require(block.number - creationBlock > 2);

        phase = Phase.Commitment;
        description.startBlock = block.number;

        emit auctionStarted();
    }


    function bid(uint _bidValue, bytes32 _bidHash) public payable {
        require(phase == Phase.Commitment);
        require(msg.value >= min_deposit);

        Bid memory _bid;
        _bid.value = _bidValue;
        _bid.hash = _bidHash;
        _bid.deposit = msg.value;

        bids_reg[msg.sender] = _bid;
    }
}