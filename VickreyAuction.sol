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

    uint startPhaseBlock;
    uint reservePrice;
    uint min_deposit;
    uint commitment_len;
    uint withdrawal_len;
    uint opening_len;

    struct Bid {
        uint value;
        bytes32 hash;
        uint deposit;
    }
    mapping(address => Bid) bids;

    event withdrawalStarted();
    event openingStarted();

    constructor(
        string memory _itemName,
        uint _reservePrice,
        uint _min_deposit,
        uint _commitment_len,
        uint _withdrawal_len,
        uint _opening_len
    ) public {
        require(_reservePrice > 0);
        require(_min_deposit > 0);
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

    
    modifier duringCommitment{
        require(phase == Phase.Commitment);
        require((block.number - startPhaseBlock) <= commitment_len);
        _;
    }
    
    modifier duringWithdrawal{
        require(phase == Phase.Withdrawal);
        require((block.number - startPhaseBlock) <= withdrawal_len);
        _;
    }
    
    modifier duringOpening{
        require(phase == Phase.Opening);
        require((block.number - startPhaseBlock) <= opening_len);
        _;
    }
    

    function startCommitment() public onlySeller {
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
    
    
    //Che succede se uno stesso indirizzo invia due bids?
    function bid(uint _bidValue, bytes32 _bidHash) public duringCommitment payable {
        require(msg.value >= min_deposit);

        Bid memory _bid;
        _bid.value = _bidValue;
        _bid.hash = _bidHash;
        _bid.deposit = msg.value;

        bids[msg.sender] = _bid;
    }
    
    
    function withdrawal() public duringWithdrawal {
        require(bids[msg.sender].deposit > 0);
        
        uint bidderWith = bids[msg.sender].deposit / 2;
        uint sellerWith = bids[msg.sender].deposit - bidderWith;
        
        //bids[msg.sender].deposit = 0;
        delete bids[msg.sender];
        
        description.seller.transfer(sellerWith);
        msg.sender.transfer(bidderWith);
        
    }
    
    function open(bytes32 _nonce) public duringOpening payable{
        require(keccak256(abi.encodePacked(bids[msg.sender].value, _nonce)) == bids[msg.sender].hash);
    }
    
}