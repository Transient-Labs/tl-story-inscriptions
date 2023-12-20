// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {IStory} from "src/IStory.sol";
import {Example721} from "src/example/Example721.sol";

contract StoryInscriptionsTest is Test {
    address[] public accounts;
    Example721 public nft;

    event CollectionStory(address indexed creatorAddress, string creatorName, string story);
    event CreatorStory(uint256 indexed tokenId, address indexed creatorAddress, string creatorName, string story);
    event Story(uint256 indexed tokenId, address indexed collectorAddress, string collectorName, string story);

    function setUp() public {
        accounts.push(makeAddr("account0"));
        accounts.push(makeAddr("account1"));
        accounts.push(makeAddr("account2"));

        nft = new Example721();
        nft.mint(1);
    }

    function test_5000WordGasEstimate() public {
        string memory story = vm.readFile("test/file_utils/lorem.txt");

        nft.addCreatorStory(1, "Socrates", story);
    }

    function test_FuzzGas(string memory story) public {
        nft.addCreatorStory(1, "Socrates", story);
    }
}
