// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.5.0/utils/Counters.sol";

contract RomanCodingTest is ERC721, Ownable {
    using Counters for Counters.Counter;

    // ===== 1. Property Variables ===== //
    Counters.Counter private _tokenIdCounter;

    // Supply
    uint public maxSupply = 10;

    // Price
    uint256 public startPrice = 8.5 ether;
    uint256 public floorPrice = 6 ether;
    uint256 public discountRate = 0.9 ether;

    // Time
    // uint256 public duration = 240 hours;
    uint256 public discountTime = 3600;
    uint256 public startAt;
    // uint256 public endAt;

    // Auction controller
    bool public isSaleActive = false;

    // ===== 2. Lifecycle Methods ===== //
    constructor() ERC721("Roman_NFT_Dutch_Auction", "Roman") {
    }

    // ===== 3. Minting Function ===== //
    function dutchAuctionMint(address to, uint256 qty) public payable {
        require(isSaleActive, "Roman NFT Dutch Auction started!");

        require(qty == 1 || qty == 2, "Please choose to mint 1 or 2 NFT");

        // Check that totalSupply is less than maxSupply
        uint256 totalSupply = _tokenIdCounter.current();
        require(totalSupply < maxSupply, "This is the end of the Roman NFT Dutch Auction, thank you!"); // No more supply

        // Check if ether value is correct
        require(msg.value == (qty * currentPrice()), "Please check the currentPrice and type in the correct ether amount to mint.");

        for(uint i = 0; i < qty; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenId);
        }

    }

    // ===== 4. Price Function ===== //
    function currentPrice() public view returns (uint256) {
        if(startAt == 0) {
            return startPrice;
        }

        if(block.timestamp > startAt + discountTime * 4) {
            return floorPrice;
        }

        // Prevent drop to 8.49999 from the beginning
        if(block.timestamp - startAt < discountTime) {
            return startPrice;
        }

        uint256 minutesElapsed = (block.timestamp - startAt) / discountTime;
        return startPrice - (discountRate ** minutesElapsed);
    }

    // ===== 5. Sale Active Function ===== //
    function dutchAuctionStart(uint256 _maxSupply, uint256 _startPrice, uint256 _discountTime, uint256 _floorPrice) public onlyOwner {
        if(isSaleActive == true) {
            return;
        }

        isSaleActive = !isSaleActive;
        maxSupply = _maxSupply;
        startPrice = _startPrice;
        discountTime = _discountTime;
        floorPrice = _floorPrice;

        startAt = block.timestamp;
        // endAt = block.timestamp + duration;
    }
}