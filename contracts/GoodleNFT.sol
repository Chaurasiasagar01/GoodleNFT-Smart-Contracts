// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.8.4;

import "./ERC721.sol";

interface IGoodleAuction {
    function openNewAuction(uint256 tokenId) external returns (bool);
}

contract GoodleNFT is ERC721 {
    IGoodleAuction public goodleAuction;
    address public owner;
    uint256 public nftCounter;
    mapping(address => bool) public isMinter;

    //==========// Modifiers //==========//

    modifier onlyMinter() {
        require(isMinter[msg.sender] == true, "ERR: AUTH FAILED");
        _;
    }

    //==========// Initializer //==========//

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        owner = msg.sender;
        isMinter[msg.sender] = true;
    }

    //==========// External Functions //==========//

    function setGoodleAuction(address _goodleAuction) external {
        require(msg.sender == owner, "ERR: AUTH FILED");
        goodleAuction = IGoodleAuction(_goodleAuction);
    }

    function setBaseURI(string memory _baseUri) external {
        require(msg.sender == owner, "ERR: AUTH FILED");
        setBaseUri(_baseUri);
    }

    function setMinter(address minter, bool actionType) external {
        require(msg.sender == owner, "ERR: AUTH FILED");
        isMinter[minter] = actionType;
    }

    function mint(string memory _nftHash) external onlyMinter returns (uint256) {
        _mint(address(goodleAuction), nftCounter, _nftHash);
        if (nftCounter > 0) {
            bool res = goodleAuction.openNewAuction(nftCounter);
            require(res == true, "ERR : AUCTION FAILED");
        }
        ++nftCounter;
        return nftCounter;
    }
}
