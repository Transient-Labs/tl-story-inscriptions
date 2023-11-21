// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*//////////////////////////////////////////////////////////////////////////
                            Custom Errors
//////////////////////////////////////////////////////////////////////////*/

/// @dev story additions are not enabled
error StoryNotEnabled();

/// @dev token does not exist
error TokenDoesNotExist();

/// @dev caller is not the token owner
error NotTokenOwner();

/// @dev caller is not the creator
error NotCreator();

/// @dev caller is not a story admin
error NotStoryAdmin();

/*//////////////////////////////////////////////////////////////////////////
                            IStory
//////////////////////////////////////////////////////////////////////////*/

/// @title Story Contract Interface
/// @dev interface id: 0x2464f17b
/// @dev previous interface id that is still supported: 0x0d23ecb9
/// @author transientlabs.xyz
/// @custom:version 5.0.0
interface IStory {
    /*//////////////////////////////////////////////////////////////////////////
                                Events
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice event describing a collection story getting added to a contract
    /// @dev this event stories creator stories on chain in the event log that apply to an entire collection
    /// @param creatorAddress - the address of the creator of the collection
    /// @param creatorName - string representation of the creator's name
    /// @param story - the story written and attached to the collection
    event CollectionStory(address indexed creatorAddress, string creatorName, string story);

    /// @notice event describing a creator story getting added to a token
    /// @dev this events stores creator stories on chain in the event log
    /// @param tokenId - the token id to which the story is attached
    /// @param creatorAddress - the address of the creator of the token
    /// @param creatorName - string representation of the creator's name
    /// @param story - the story written and attached to the token id
    event CreatorStory(uint256 indexed tokenId, address indexed creatorAddress, string creatorName, string story);

    /// @notice event describing a collector story getting added to a token
    /// @dev this events stores collector stories on chain in the event log
    /// @param tokenId - the token id to which the story is attached
    /// @param collectorAddress - the address of the collector of the token
    /// @param collectorName - string representation of the collectors's name
    /// @param story - the story written and attached to the token id
    event Story(uint256 indexed tokenId, address indexed collectorAddress, string collectorName, string story);

    /*//////////////////////////////////////////////////////////////////////////
                                Story Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice function to let the creator add a story to the collection they have created
    /// @dev depending on the implementation, this function may be restricted in various ways, such as
    ///      limiting the number of times the creator may write a story.
    /// @dev this function MUST emit the CollectionStory event each time it is called
    /// @dev this function MUST implement logic to restrict access to only the creator
    /// @param creatorName - string representation of the creator's name
    /// @param story - the story written and attached to the token id
    function addCollectionStory(string calldata creatorName, string calldata story) external;

    /// @notice function to let the creator add a story to any token they have created
    /// @dev depending on the implementation, this function may be restricted in various ways, such as
    ///      limiting the number of times the creator may write a story.
    /// @dev this function MUST emit the CreatorStory event each time it is called
    /// @dev this function MUST implement logic to restrict access to only the creator
    /// @dev this function MUST revert if a story is written to a non-existent token
    /// @param tokenId - the token id to which the story is attached
    /// @param creatorName - string representation of the creator's name
    /// @param story - the story written and attached to the token id
    function addCreatorStory(uint256 tokenId, string calldata creatorName, string calldata story) external;

    /// @notice function to let collectors add a story to any token they own
    /// @dev depending on the implementation, this function may be restricted in various ways, such as
    ///      limiting the number of times a collector may write a story.
    /// @dev this function MUST emit the Story event each time it is called
    /// @dev this function MUST implement logic to restrict access to only the owner of the token
    /// @dev this function MUST revert if a story is written to a non-existent token
    /// @param tokenId - the token id to which the story is attached
    /// @param collectorName - string representation of the collectors's name
    /// @param story - the story written and attached to the token id
    function addStory(uint256 tokenId, string calldata collectorName, string calldata story) external;
}
