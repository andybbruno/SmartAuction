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
    //remove public
    Phase public phase;

    uint startPhaseBlock;
    uint reservePrice;
    uint min_deposit;
    uint commitment_len;
    uint withdrawal_len;
    uint opening_len;

    address payable highestBidder;
    uint highestBid;
    uint secondHighestBid;
    bool firstOpen = true;

    struct Bid {
        uint value;
        bytes32 nonce;
        bytes32 hash;
        uint deposit;
    }
    //remove public
    mapping(address => Bid) bids;

    event withdrawalStarted();
    event openingStarted();

    event withdrawalExecuted(address bidder, uint value, address seller, uint val);


    constructor(
        string memory _itemName,
        uint _reservePrice,
        uint _min_deposit,
        uint _commitment_len,
        uint _withdrawal_len,
        uint _opening_len
    ) public {
        require(_reservePrice > 0);
        require(_min_deposit >= _reservePrice);
        require(_commitment_len > 0);
        require(_withdrawal_len > 0);
        require(_opening_len > 0);

        description.seller = msg.sender;
        description.itemName = _itemName;


        phase = Phase.GracePeriod;
        reservePrice = _reservePrice;
        min_deposit = _min_deposit;
        commitment_len = _commitment_len;
        withdrawal_len = _withdrawal_len;
        opening_len = _opening_len;

        startPhaseBlock = block.number;
    }


    modifier duringCommitment {
        require(phase == Phase.Commitment);
        require((block.number - startPhaseBlock) <= commitment_len);
        _;
    }

    modifier duringWithdrawal {
        require(phase == Phase.Withdrawal);
        require((block.number - startPhaseBlock) <= withdrawal_len);
        _;
    }

    modifier duringOpening {
        require(phase == Phase.Opening);
        require((block.number - startPhaseBlock) <= opening_len);
        _;
    }


    function activateAuction() public onlySeller {
        require(phase == Phase.GracePeriod);
        //20 blocchi sono 5 minuti (+-)
        require(block.number - startPhaseBlock > 2);

        phase = Phase.Commitment;
        description.startBlock = block.number;
        startPhaseBlock = block.number;

        emit auctionStarted();
    }


    function startWithdrawal() public onlySeller {
        require(phase == Phase.Commitment);
        require((block.number - startPhaseBlock) > commitment_len);

        phase = Phase.Withdrawal;
        startPhaseBlock = block.number;

        emit withdrawalStarted();
    }


    function startOpening() public onlySeller {
        require(phase == Phase.Withdrawal);
        require((block.number - startPhaseBlock) > withdrawal_len);

        phase = Phase.Opening;
        startPhaseBlock = block.number;

        emit openingStarted();
    }



    function finalize() public onlySeller {
        require(phase == Phase.Opening);
        require((block.number - startPhaseBlock) > opening_len);

        if (highestBidder != address(0)) {
            description.winnerAddress = highestBidder;
            description.winnerBid = secondHighestBid;
            
            //refund the winner
            highestBidder.transfer(highestBid - secondHighestBid);
        
            //send ehter to the seller of the item
            description.seller.transfer(description.winnerBid);
        }
        
        phase = Phase.Finished;
        emit auctionFinished(description.winnerAddress, description.winnerBid, address(this).balance);
        
    }




    function bid(bytes32 _bidHash) public duringCommitment payable {
        require(msg.value >= min_deposit);
        
        //ensure that is the sender haven't sent another bid previously
        require(bids[msg.sender].value == 0);
        
        Bid memory _bid;
        _bid.hash = _bidHash;
        _bid.deposit = msg.value;

        bids[msg.sender] = _bid;

    }


    function withdrawal() public duringWithdrawal {
        require(bids[msg.sender].deposit > 0);

        uint bidderRefund = bids[msg.sender].deposit / 2;
        uint sellerRefund = bids[msg.sender].deposit - bidderRefund;

        //bids[msg.sender].deposit = 0;
        delete bids[msg.sender];

        description.seller.transfer(sellerRefund);
        msg.sender.transfer(bidderRefund);
        emit withdrawalExecuted(msg.sender, bidderRefund, description.seller, sellerRefund);
    }


    function open(bytes32 _nonce) public duringOpening payable {
        require(keccak256(abi.encodePacked(msg.value, _nonce)) == bids[msg.sender].hash);

        //refund the deposit
        uint deposit = bids[msg.sender].deposit;
        bids[msg.sender].deposit = 0;
        msg.sender.transfer(deposit);
        
        //serve??
        bids[msg.sender].value = msg.value;
        bids[msg.sender].nonce = _nonce;

        //if it is the first opening
        if (firstOpen) {
            highestBidder = msg.sender;
            highestBid = msg.value;
            
            //if there is only one bid, the winner pays at least the reservePrice
            secondHighestBid = reservePrice;
            
            firstOpen = false;
        } else {
            //if the msg.value is more than the highest bid
            if (msg.value > highestBid) {
                //the highest bid becomes the second highest bid
                secondHighestBid = highestBid;

                //now we need to refund the bidder of the (old) highest bid
                refund(highestBidder, highestBid);

                //set the new highest bidder and its own bid
                highestBidder = msg.sender;
                highestBid = msg.value;

            } else {
                //check whether the msg.value is higher than the second highest bid
                if (msg.value > secondHighestBid) secondHighestBid = msg.value;
                
                //since the current opening is not the highest we can refund the sender
                refund(msg.sender, msg.value);
            }
        }
    }


    function refund(address payable _dest, uint value) internal {
        _dest.transfer(value);
    }
}