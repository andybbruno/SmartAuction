pragma solidity ^ 0.5.1;

/// @title GenerateBid contract
/// @author Andrea Bruno 585457
/// @notice This contract helps people in making bids. If deployed locally, no gas is required.
/// @dev The following comments are written using the Solidity NatSpec Format.
contract GenerateBid {

    // Every bid is composed by one value, one nonce and one hash.
    struct BidHelper {
        uint value;
        bytes32 nonce;
        bytes32 hash;
    }

    BidHelper public bid;

    /// @notice This function generates the nonce and the hash needed in the Vickrey Auction.
    /// @param _bidValue is the desired bid.
    function generateBid(uint _bidValue) public {
        bid.value = _bidValue;
        bid.nonce = keccak256(abi.encodePacked(block.timestamp));
        bid.hash = keccak256(abi.encodePacked(_bidValue, bid.nonce));
    }
}
