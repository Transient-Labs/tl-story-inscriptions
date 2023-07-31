// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {StoryContract} from "src/StoryContract.sol";

contract Example721 is ERC721, StoryContract, Ownable {
    uint256 private _counter;

    constructor(bool enabled) ERC721("Test", "TST") StoryContract(enabled) Ownable() {}

    function mint(uint256 numToMint) external onlyOwner {
        for (uint256 i = 0; i < numToMint; i++) {
            _counter++;
            _mint(msg.sender, _counter);
        }
    }

    function _isStoryAdmin(address potentialAdmin) internal view override (StoryContract) returns (bool) {
        return owner() == potentialAdmin;
    }

    function _tokenExists(uint256 tokenId) internal view override (StoryContract) returns (bool) {
        return _exists(tokenId);
    }

    function _isTokenOwner(address potentialOwner, uint256 tokenId)
        internal
        view
        override (StoryContract)
        returns (bool)
    {
        return ownerOf(tokenId) == potentialOwner;
    }

    function _isCreator(address potentialCreator, uint256 /* tokenId */ )
        internal
        view
        override (StoryContract)
        returns (bool)
    {
        return owner() == potentialCreator;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (ERC721, StoryContract)
        returns (bool)
    {
        return ERC721.supportsInterface(interfaceId) || StoryContract.supportsInterface(interfaceId);
    }
}
