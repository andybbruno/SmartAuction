pragma solidity ^ 0.5.1;

contract GenerateBid {

    struct BidHelper {
        uint value;
        bytes32 nonce;
        bytes32 hash;
    }

    BidHelper public bid;

    function generateBid(uint _bidValue) public {
        bid.value = _bidValue;
        bid.nonce = keccak256(abi.encodePacked(block.timestamp));
        bid.hash = keccak256(abi.encodePacked(_bidValue, bid.nonce));
    }
}