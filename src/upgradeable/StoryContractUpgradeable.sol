// SPDX-License-Identifier: Apache-2.0

/// @title Story Contract
/// @dev upgradeable (proxy really), inheritable abstract contract implementing the Story Contract interface
/// @author transientlabs.xyz
/// Version 2.0.0

/*
    ____        _ __    __   ____  _ ________                     __ 
   / __ )__  __(_) /___/ /  / __ \(_) __/ __/__  ________  ____  / /_
  / __  / / / / / / __  /  / / / / / /_/ /_/ _ \/ ___/ _ \/ __ \/ __/
 / /_/ / /_/ / / / /_/ /  / /_/ / / __/ __/  __/ /  /  __/ / / / /__ 
/_____/\__,_/_/_/\__,_/  /_____/_/_/ /_/  \___/_/   \___/_/ /_/\__(_)

*/

pragma solidity 0.8.17;

///////////////////// IMPORTS /////////////////////

import { Initializable } from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import { ERC165Upgradeable } from "openzeppelin-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import { IStory } from "../IStory.sol";

/*//////////////////////////////////////////////////////////////////////////
                            Custom Errors
//////////////////////////////////////////////////////////////////////////*/

/// @dev story additions are not enabled
error StoryNotEnabled();

/// @dev token does not exist
error TokenDoesNotExist();

/// @dev caller is not the token owner
error NotTokenOwner();

/// @dev caller is not the token creator
error NotTokenCreator();

/// @dev caller is not a story admin
error NotStoryAdmin();

/*//////////////////////////////////////////////////////////////////////////
                            Story Contract
//////////////////////////////////////////////////////////////////////////*/

abstract contract StoryContractUpgradeable is Initializable, IStory, ERC165Upgradeable {

    /*//////////////////////////////////////////////////////////////////////////
                                State Variables
    //////////////////////////////////////////////////////////////////////////*/

    bool public storyEnabled;

    /*//////////////////////////////////////////////////////////////////////////
                                Modifiers
    //////////////////////////////////////////////////////////////////////////*/

    modifier storyMustBeEnabled {
        if (!storyEnabled) { revert StoryNotEnabled(); }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Initializer
    //////////////////////////////////////////////////////////////////////////*/

    /// @param enabled is a bool to enable or disable Story addition
    function __StoryContractUpgradeable_init(bool enabled) internal {
        __StoryContractUpgradeable_init_unchained(enabled);
    }

    /// @param enabled is a bool to enable or disable Story addition
    function __StoryContractUpgradeable_init_unchained(bool enabled) internal {
        storyEnabled = enabled;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Story Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev function to set story enabled/disabled
    /// @dev requires story admin
    function setStoryEnabled(bool enabled) external {
        if (!_isStoryAdmin(msg.sender)) { revert NotStoryAdmin(); }
        storyEnabled = enabled;
    }

    /// @dev see { IStory.addCreatorStory }
    function addCreatorStory(uint256 tokenId, string calldata creatorName, string calldata story) external storyMustBeEnabled {
        if (!_tokenExists(tokenId)) { revert TokenDoesNotExist(); }
        if (!_isCreator(msg.sender, tokenId)) { revert NotTokenCreator(); }
        
        emit CreatorStory(tokenId, msg.sender, creatorName, story);
    }

    /// @dev see { IStory.addStory }
    function addStory(uint256 tokenId, string calldata collectorName, string calldata story) external storyMustBeEnabled {
        if (!_tokenExists(tokenId)) { revert TokenDoesNotExist(); }
        if (!_isTokenOwner(msg.sender, tokenId)) {revert NotTokenOwner();}

        emit Story(tokenId, msg.sender, collectorName, story);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Hooks
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev function to allow access to enabling/disabling story
    function _isStoryAdmin(address potentialAdmin) internal view virtual returns (bool);

    /// @dev function to check if a token exists on the token contract
    function _tokenExists(uint256 tokenId) internal view virtual returns (bool);

    /// @dev function to check ownership of a token
    function _isTokenOwner(address potentialOwner, uint256 tokenId) internal view virtual returns (bool);

    /// @dev function to check creatorship of a token
    function _isCreator(address potentialCreator, uint256 tokenId) internal view virtual returns (bool);

    /*//////////////////////////////////////////////////////////////////////////
                                Overrides
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev see { ERC165.supportsInterface }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable) returns (bool) {
        return interfaceId == type(IStory).interfaceId || ERC165Upgradeable.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Upgradeability Gap
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev gap variable - see https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    uint256[50] private _gap;
}