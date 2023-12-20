// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC165} from "lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {IStory} from "src/IStory.sol";

/// @title Story Contract
/// @dev Standalone, inheritable abstract contract implementing the Story Contract interface
/// @author transientlabs.xyz
/// @custom:version 6.0.0
abstract contract StoryContract is IStory, ERC165 {
    /*//////////////////////////////////////////////////////////////////////////
                                State Variables
    //////////////////////////////////////////////////////////////////////////*/

    bool public storyEnabled;

    /*//////////////////////////////////////////////////////////////////////////
                                Errors
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Story additions are not enabled
    error StoryNotEnabled();

    /// @dev Token does not exist
    error TokenDoesNotExist();

    /// @dev Caller is not the token owner
    error NotTokenOwner();

    /// @dev Caller is not the creator
    error NotCreator();

    /// @dev Caller is not a story admin
    error NotStoryAdmin();

    /*//////////////////////////////////////////////////////////////////////////
                                Modifiers
    //////////////////////////////////////////////////////////////////////////*/

    modifier storyMustBeEnabled() {
        if (!storyEnabled) revert StoryNotEnabled();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Constructor
    //////////////////////////////////////////////////////////////////////////*/

    /// @param enabled A boolean to enable or disable Story additions
    constructor(bool enabled) {
        storyEnabled = enabled;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Story Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Function to set story enabled/disabled
    /// @dev Requires story admin
    /// @param enabled A boolean setting to enable or disable Story additions
    function setStoryEnabled(bool enabled) external {
        if (!_isStoryAdmin(msg.sender)) revert NotStoryAdmin();
        storyEnabled = enabled;
    }

    /// @inheritdoc IStory
    function addCollectionStory(string calldata creatorName, string calldata story) external {
        if (!_isCreator(msg.sender)) revert NotCreator();

        emit CollectionStory(msg.sender, creatorName, story);
    }

    /// @inheritdoc IStory
    function addCreatorStory(uint256 tokenId, string calldata creatorName, string calldata story) external {
        if (!_tokenExists(tokenId)) revert TokenDoesNotExist();
        if (!_isCreator(msg.sender, tokenId)) revert NotCreator();

        emit CreatorStory(tokenId, msg.sender, creatorName, story);
    }

    /// @inheritdoc IStory
    function addStory(uint256 tokenId, string calldata collectorName, string calldata story)
        external
        storyMustBeEnabled
    {
        if (!_tokenExists(tokenId)) revert TokenDoesNotExist();
        if (!_isTokenOwner(msg.sender, tokenId)) revert NotTokenOwner();

        emit Story(tokenId, msg.sender, collectorName, story);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Hooks
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Function to allow access to enabling/disabling story
    /// @param potentialAdmin The address to check for admin priviledges
    function _isStoryAdmin(address potentialAdmin) internal view virtual returns (bool);

    /// @dev Function to check if a token exists on the token contract
    /// @param tokenId The token id to check for existence
    function _tokenExists(uint256 tokenId) internal view virtual returns (bool);

    /// @dev Function to check ownership of a token
    /// @param potentialOwner The address to check for ownership of `tokenId`
    /// @param tokenId The token id to check ownership against
    function _isTokenOwner(address potentialOwner, uint256 tokenId) internal view virtual returns (bool);

    /// @dev Function to check creatorship of the collection
    /// @param potentialCreator The address to check creatorship of the collection
    function _isCreator(address potentialCreator) internal view virtual returns (bool);

    /// @dev Function to check creatorship of a token
    /// @param potentialCreator The address to check creatorship of `tokenId`
    /// @param tokenId The token id to check creatorship against
    function _isCreator(address potentialCreator, uint256 tokenId) internal view virtual returns (bool);

    /*//////////////////////////////////////////////////////////////////////////
                                Overrides
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IStory).interfaceId || interfaceId == 0x0d23ecb9 // support interface id for previous IStory interface, since this technically implements it
            || ERC165.supportsInterface(interfaceId);
    }
}
