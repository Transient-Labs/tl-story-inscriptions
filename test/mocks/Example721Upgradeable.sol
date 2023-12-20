// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721Upgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";
import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {StoryContractUpgradeable} from "src/upgradeable/StoryContractUpgradeable.sol";

contract Example721Upgradeable is ERC721Upgradeable, OwnableUpgradeable, StoryContractUpgradeable {
    uint256 private _counter;

    function initialize(bool enabled) external initializer {
        __ERC721_init("TEST", "TST");
        __Ownable_init(msg.sender);
        __StoryContract_init(enabled);
    }

    function _exists(uint256 tokenId) private view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function mint(uint256 numToMint) external onlyOwner {
        for (uint256 i = 0; i < numToMint; i++) {
            _counter++;
            _mint(msg.sender, _counter);
        }
    }

    function _isStoryAdmin(address potentialAdmin) internal view override(StoryContractUpgradeable) returns (bool) {
        return owner() == potentialAdmin;
    }

    function _tokenExists(uint256 tokenId) internal view override(StoryContractUpgradeable) returns (bool) {
        return _exists(tokenId);
    }

    function _isTokenOwner(address potentialOwner, uint256 tokenId)
        internal
        view
        override(StoryContractUpgradeable)
        returns (bool)
    {
        return ownerOf(tokenId) == potentialOwner;
    }

    function _isCreator(address potentialCreator) internal view override(StoryContractUpgradeable) returns (bool) {
        return owner() == potentialCreator;
    }

    function _isCreator(address potentialCreator, uint256 /* tokenId */ )
        internal
        view
        override(StoryContractUpgradeable)
        returns (bool)
    {
        return owner() == potentialCreator;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, StoryContractUpgradeable)
        returns (bool)
    {
        return
            ERC721Upgradeable.supportsInterface(interfaceId) || StoryContractUpgradeable.supportsInterface(interfaceId);
    }
}
