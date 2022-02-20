// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

import {UUPSUpgradeable, AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IGoodleNFT {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract GoodleAuction is Initializable, UUPSUpgradeable {
    using SafeMath for uint256;

    IGoodleNFT public goodleNFT;
    address public owner;
    address public goodleVault;
    address private highestBidder;

    uint256 public baseBidAmount;
    uint256 private auctionStartTime;
    uint256 private currentBiddingTokenId;
    uint256 private highestBid;
    uint256 private bidsCounter;

    struct AuctionHistory {
        uint256 startTime;
        uint256 endTime;
        address winner;
        uint256 winBid;
        uint256 totalBids;
    }

    mapping(uint256 => AuctionHistory) public auctionHistory;

    modifier onlyOwner() {
        require(msg.sender == owner, "ERR: AUTH FAILED");
        _;
    }

    event LogBid(
        uint256 indexed currentBiddingTokenId,
        address indexed NewBidder,
        uint256 NewAmount,
        address indexed OldBidder,
        uint256 OldBidAmt
    );
    event LogAuctionEnd(
        uint256 indexed TokenId,
        address indexed Winner,
        uint256 Amount,
        uint256 totalBids
    );
    event LogAuctionStart(uint256 indexed TokenId);

    receive() external payable {}

    //==========// Initializer //==========//

    function initialize(address _goodleNFT, address _goodleVault)
        public
        initializer
    {
        owner = msg.sender;
        baseBidAmount = 0.01 ether;
        goodleVault = _goodleVault;
        goodleNFT = IGoodleNFT(_goodleNFT);
    }

    function setGoodleNFT(address _goodleNFT) external onlyOwner {
        goodleNFT = IGoodleNFT(_goodleNFT);
    }

    function setGoodleVault(address _goodleVault) external onlyOwner {
        goodleVault = _goodleVault;
    }

    function setBaseBidAmount(uint256 _baseBidAmount) external onlyOwner {
        baseBidAmount = _baseBidAmount;
    }

    function openNewAuction(uint256 _tokenId) external payable returns (bool) {
        require(msg.sender == address(goodleNFT), "ERR : AUTH FAILED");

        if (highestBidder != address(0x0) && bidsCounter != 0) {
            // transfer nft to user
            goodleNFT.transferFrom(
                address(this),
                highestBidder,
                currentBiddingTokenId
            );

            (bool sent, ) = goodleVault.call{value: highestBid}("");
            require(sent, "ERR : TRANSFER FAILED");
        } else {
            goodleNFT.transferFrom(address(this), owner, currentBiddingTokenId);
        }

        AuctionHistory memory history = AuctionHistory({
            startTime: auctionStartTime,
            endTime: block.timestamp,
            winner: highestBidder,
            winBid: highestBid,
            totalBids: bidsCounter
        });

        auctionHistory[currentBiddingTokenId] = history;

        emit LogAuctionEnd(
            currentBiddingTokenId,
            highestBidder,
            highestBid,
            bidsCounter
        );

        auctionStartTime = block.timestamp;
        currentBiddingTokenId = _tokenId;
        highestBidder = address(0x0);
        highestBid = baseBidAmount;
        bidsCounter = 0;

        emit LogAuctionStart(_tokenId);
        return true;
    }

    function bid() external payable {
        require(msg.value > 0, "ERR : ZERO BID AMT");
        require(msg.value > highestBid, "ERR : LOW BID AMT");

        address oldBidder = highestBidder;
        uint256 oldBidAmt = highestBid;
        // bool sent = payable(oldBidder).send(oldBidAmt);
        if (highestBidder != address(0x0) && bidsCounter != 0) {
            (bool sent, ) = goodleVault.call{value: highestBid}("");
            require(sent, "ERR : TRANSFER FAILED");
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        ++bidsCounter;

        emit LogBid(
            currentBiddingTokenId,
            msg.sender,
            msg.value,
            oldBidder,
            oldBidAmt
        );
    }

    function getCurrentAuctionInfo()
        external
        view
        returns (
            uint256,
            uint256,
            address,
            uint256,
            uint256
        )
    {
        return (
            currentBiddingTokenId,
            auctionStartTime,
            highestBidder,
            highestBid,
            bidsCounter
        );
    }

    function getPreviousAuctionInfo(uint256 _tokenID)
        external
        view
        returns (
            uint256,
            uint256,
            address,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _tokenID,
            auctionHistory[_tokenID].startTime,
            auctionHistory[_tokenID].winner,
            auctionHistory[_tokenID].winBid,
            auctionHistory[_tokenID].totalBids,
            auctionHistory[_tokenID].endTime
        );
    }

    function upgradeTo(address newImplementation_)
        external
        virtual
        override
        onlyOwner
    {
        _authorizeUpgrade(newImplementation_);
        _upgradeTo(newImplementation_);
    }

    //==========// Internal Functions //==========//
    function _authorizeUpgrade(address newImplementation_)
        internal
        virtual
        override
        onlyOwner
    {
        require(
            AddressUpgradeable.isContract(newImplementation_),
            "ERR : NOT CONTRACT"
        );
    }
}
