// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {IStory} from "src/IStory.sol";

contract Example721 is ERC721, Ownable, IStory {
    uint256 private _counter;

    constructor() ERC721("Test", "TEST") Ownable(msg.sender) {}
    
    /// @notice Internal function to check if a token exists
    function _exists(uint256 tokenId) private view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /// @notice Function to mint tokens
    /// @dev Not optimized
    function mint(uint256 numToMint) external onlyOwner {
        for (uint256 i = 0; i < numToMint; i++) {
            _counter++;
            _mint(msg.sender, _counter);
        }
    }

    /// @inheritdoc IStory
    function addCollectionStory(string calldata creatorName, string calldata story) external onlyOwner {
        emit CollectionStory(msg.sender, creatorName, story);
    }

    /// @inheritdoc IStory
    function addCreatorStory(uint256 tokenId, string calldata creatorName, string calldata story) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        emit CreatorStory(tokenId, msg.sender, creatorName, story);
    }

    /// @inheritdoc IStory
    function addStory(uint256 tokenId, string calldata collectorName, string calldata story) external {
        require(ownerOf(tokenId) == msg.sender, "msg.sender is not the token owner");
        emit Story(tokenId, msg.sender, collectorName, story);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || type(IStory).interfaceId == interfaceId || interfaceId == 0x0d23ecb9; // support previous version of interface as it is backwards compatible
    }
}