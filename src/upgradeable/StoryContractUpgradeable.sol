// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {ERC165Upgradeable} from
    "lib/openzeppelin-contracts-upgradeable/contracts/utils/introspection/ERC165Upgradeable.sol";
import {IStory} from "src/IStory.sol";

/// @title Story Contract
/// @dev Upgradeable, inheritable abstract contract implementing the Story Contract interface
/// @author transientlabs.xyz
/// @custom:version 6.0.0
abstract contract StoryContractUpgradeable is Initializable, IStory, ERC165Upgradeable {
    /*//////////////////////////////////////////////////////////////////////////
                                    Storage
    //////////////////////////////////////////////////////////////////////////*/

    /// @custom:storage-location erc7201:transientlabs.storage.StoryContract
    struct StoryContractStorage {
        bool storyEnabled;
    }

    // keccak256(abi.encode(uint256(keccak256("transientlabs.storage.StoryContract")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant StoryContractStorageLocation =
        0x476a5df056619be505605dfc1f43794cb59f969177cd944c1aa0f27eb23dbf00;

    /// @dev private function to get storage location with ERC-2701 namespaced storage
    function _getStoryContractStorage() private pure returns (StoryContractStorage storage $) {
        assembly {
            $.slot := StoryContractStorageLocation
        }
    }

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
        StoryContractStorage storage $ = _getStoryContractStorage();
        if (!$.storyEnabled) revert StoryNotEnabled();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Initializer
    //////////////////////////////////////////////////////////////////////////*/

    /// @param enabled A bool to enable or disable Story addition
    function __StoryContract_init(bool enabled) internal {
        __StoryContract_init_unchained(enabled);
    }

    /// @param enabled A bool to enable or disable Story addition
    function __StoryContract_init_unchained(bool enabled) internal {
        StoryContractStorage storage $ = _getStoryContractStorage();
        $.storyEnabled = enabled;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Story Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to see if story is enabled/disabled
    function storyEnabled() external view returns (bool) {
        StoryContractStorage storage $ = _getStoryContractStorage();
        return $.storyEnabled;
    }

    /// @notice Function to set story enabled/disabled
    /// @dev Requires story admin
    /// @param enabled A boolean setting to enable or disable Story additions
    function setStoryEnabled(bool enabled) external {
        if (!_isStoryAdmin(msg.sender)) revert NotStoryAdmin();
        StoryContractStorage storage $ = _getStoryContractStorage();
        $.storyEnabled = enabled;
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

    /// @inheritdoc ERC165Upgradeable
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable) returns (bool) {
        return interfaceId == type(IStory).interfaceId || interfaceId == 0x0d23ecb9 // support interface id for previous IStory interface, since this technically implements it
            || ERC165Upgradeable.supportsInterface(interfaceId);
    }
}
