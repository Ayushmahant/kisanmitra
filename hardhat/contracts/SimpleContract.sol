// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SimpleContract {
    struct Item {
        string name;
        uint256 quantity;
        string imageUrl;
        address seller;
    }

    Item[] public auctionItems;

    event ItemAdded(uint256 itemId, string name, uint256 quantity, string imageUrl, address seller);

    function addAuctionItem(string memory _name, uint256 _quantity, string memory _imageUrl) public {
        auctionItems.push(Item(_name, _quantity, _imageUrl, msg.sender));
        emit ItemAdded(auctionItems.length - 1, _name, _quantity, _imageUrl, msg.sender);
    }

    function getAuctionItem(uint256 index) public view returns (string memory, uint256, string memory, address) {
        require(index < auctionItems.length, "Invalid index");
        Item memory item = auctionItems[index];
        return (item.name, item.quantity, item.imageUrl, item.seller);
    }

    function getAllAuctionItems() public view returns (Item[] memory) {
        return auctionItems;
    }
}
