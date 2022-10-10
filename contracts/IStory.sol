// SPDX-License-Identfier: Apache-2.0

/// @title Story Contract Interface
/// @author transientlabs.xyz

/**
    ____        _ __    __   ____  _ ________                     __ 
   / __ )__  __(_) /___/ /  / __ \(_) __/ __/__  ________  ____  / /_
  / __  / / / / / / __  /  / / / / / /_/ /_/ _ \/ ___/ _ \/ __ \/ __/
 / /_/ / /_/ / / / /_/ /  / /_/ / / __/ __/  __/ /  /  __/ / / / /_  
/_____/\__,_/_/_/\__,_/  /_____/_/_/ /_/  \___/_/   \___/_/ /_/\__/  
                                                                     
  ______                      _            __     __          __        
 /_  __/________ _____  _____(_)__  ____  / /_   / /   ____ _/ /_  _____
  / / / ___/ __ `/ __ \/ ___/ / _ \/ __ \/ __/  / /   / __ `/ __ \/ ___/
 / / / /  / /_/ / / / (__  ) /  __/ / / / /_   / /___/ /_/ / /_/ (__  ) 
/_/ /_/   \__,_/_/ /_/____/_/\___/_/ /_/\__/  /_____/\__,_/_.___/____/  
                                                                        
*/

pragma solidity ^0.8.14;

interface IStory {

    /// @notice this event is the cheapest storage option for stories
    /// @dev this event provides the backbone of the Story Contract and how story chains can be comprised on-chain
    event Story(uint256 indexed tokenId, address indexed authorAddress, string author, string story);

    /// @notice function to let collectors add a story to the token they own
    /// @dev depending on the implementation, this function may be restricted in various ways, such as
    ///      limiting the number of times a collector may write a story.
    /// @dev this function MUST emit the Story event each time it is called
    /// @dev development testing showed that stories up to 5,000 words were less then 0.01 eth depending on the gas.
    function addStory(uint256 tokenId, string calldata author, string calldata story) external;
}