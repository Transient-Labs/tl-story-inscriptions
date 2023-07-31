// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {IStory} from "../src/IStory.sol";
import {NotTokenCreator, NotTokenOwner, StoryNotEnabled, TokenDoesNotExist, NotStoryAdmin} from "../src/IStory.sol";
import {Example721} from "./mocks/Example721.sol";

contract StoryContractTest is Test {
    address[] public accounts;
    Example721 public contractWithStory;
    Example721 public contractNoStory;

    event CreatorStory(uint256 indexed tokenId, address indexed creatorAddress, string creatorName, string story);
    event Story(uint256 indexed tokenId, address indexed collectorAddress, string collectorName, string story);

    function setUp() public {
        accounts.push(makeAddr("account0"));
        accounts.push(makeAddr("account1"));
        accounts.push(makeAddr("account2"));

        contractWithStory = new Example721(true);
        contractWithStory.mint(4);
        contractWithStory.transferFrom(address(this), accounts[0], 1);
        contractWithStory.transferFrom(address(this), accounts[1], 2);
        contractWithStory.transferFrom(address(this), accounts[2], 3);

        contractNoStory = new Example721(false);
        contractNoStory.mint(4);
        contractNoStory.transferFrom(address(this), accounts[0], 1);
        contractNoStory.transferFrom(address(this), accounts[1], 2);
        contractNoStory.transferFrom(address(this), accounts[2], 3);
    }

    ///////////////////// INITIALIZATION TESTS /////////////////////

    function testStoryEnabledOrDisabled() public {
        assertTrue(contractWithStory.storyEnabled());
        assertFalse(contractNoStory.storyEnabled());
    }

    function testOwnership() public {
        assertEq(contractWithStory.owner(), address(this));
        assertEq(contractNoStory.owner(), address(this));
    }

    ///////////////////// STORY ENABLED/DISABLED TESTS /////////////////////

    function testSetStoryEnabled(bool enabled) public {
        contractWithStory.setStoryEnabled(enabled);
        assertEq(contractWithStory.storyEnabled(), enabled);
        contractNoStory.setStoryEnabled(enabled);
        assertEq(contractNoStory.storyEnabled(), enabled);
    }

    function testSetStoryEnabledNotAllowed(address addy) public {
        if (addy != address(this)) {
            vm.startPrank(addy, addy);

            vm.expectRevert(NotStoryAdmin.selector);
            contractWithStory.setStoryEnabled(false);

            vm.expectRevert(NotStoryAdmin.selector);
            contractNoStory.setStoryEnabled(true);

            vm.stopPrank();
        }
    }

    ///////////////////// ERC165 TESTS /////////////////////

    function testERC165() public {
        assertTrue(contractWithStory.supportsInterface(type(IStory).interfaceId));
        assertTrue(contractNoStory.supportsInterface(type(IStory).interfaceId));
    }

    ///////////////////// STORY ENABLED TESTS /////////////////////

    function testAddCreatorStory() public {
        for (uint256 i = 0; i < 4; i++) {
            uint256 id = i + 1;
            vm.expectEmit(true, true, false, true, address(contractWithStory));
            emit CreatorStory(id, address(this), "XCOPY", "I AM XCOPY");
            contractWithStory.addCreatorStory(id, "XCOPY", "I AM XCOPY");
        }
    }

    function testExpectRevertAddCreatorStory() public {
        // revert for not being the token creator
        for (uint256 i = 0; i < 3; i++) {
            uint256 id = i + 1;

            vm.prank(accounts[i], accounts[i]);
            vm.expectRevert(NotTokenCreator.selector);
            contractWithStory.addCreatorStory(id, "XCOPY", "I AM XCOPY");
        }

        // revert for not being a token that exists
        vm.expectRevert(TokenDoesNotExist.selector);
        contractWithStory.addCreatorStory(5, "XCOPY", "I AM XCOPY");
    }

    function testAddStory() public {
        for (uint256 i = 0; i < 3; i++) {
            uint256 id = i + 1;

            vm.expectEmit(true, true, false, true, address(contractWithStory));
            emit Story(id, accounts[i], "NOT XCOPY", "I AM NOT XCOPY");

            vm.prank(accounts[i], accounts[i]);
            contractWithStory.addStory(id, "NOT XCOPY", "I AM NOT XCOPY");
        }

        vm.expectEmit(true, true, false, true, address(contractWithStory));
        emit Story(4, address(this), "NOT XCOPY", "I AM NOT XCOPY");
        contractWithStory.addStory(4, "NOT XCOPY", "I AM NOT XCOPY");
    }

    function testExpectRevertAddStory() public {
        // revert for not being the token owner
        for (uint256 i = 0; i < 3; i++) {
            uint256 id = i + 1;

            vm.expectRevert(NotTokenOwner.selector);
            contractWithStory.addStory(id, "NOT XCOPY", "I AM NOT XCOPY");
        }

        // revert for not being a token that exists
        vm.expectRevert(TokenDoesNotExist.selector);
        contractWithStory.addStory(5, "NOT XCOPY", "I AM NOT XCOPY");
    }

    ///////////////////// STORY DISABLED TESTS /////////////////////

    function testExpectRevertDisabledAddCreatorStory() public {
        for (uint256 i = 0; i < 4; i++) {
            uint256 id = i + 1;
            vm.expectRevert(StoryNotEnabled.selector);
            contractNoStory.addCreatorStory(id, "XCOPY", "I AM XCOPY");
        }
    }

    function testExpectRevertDisabledAddStory() public {
        for (uint256 i = 0; i < 3; i++) {
            uint256 id = i + 1;

            vm.expectRevert(StoryNotEnabled.selector);
            vm.prank(accounts[i], accounts[i]);
            contractNoStory.addStory(id, "NOT XCOPY", "I AM NOT XCOPY");
        }

        vm.expectRevert(StoryNotEnabled.selector);
        contractNoStory.addStory(4, "NOT XCOPY", "I AM NOT XCOPY");
    }

    ///////////////////// TRANSFER AND WRITE STORY TESTS /////////////////////

    function testTransferAndAddCreatorStory() public {
        // contract with story
        vm.prank(accounts[0], accounts[0]);
        contractWithStory.transferFrom(accounts[0], accounts[1], 1);
        vm.expectEmit(true, true, false, true, address(contractWithStory));
        emit CreatorStory(1, address(this), "XCOPY", "I AM XCOPY");
        contractWithStory.addCreatorStory(1, "XCOPY", "I AM XCOPY");

        // contract no story
        vm.prank(accounts[0], accounts[0]);
        contractNoStory.transferFrom(accounts[0], accounts[1], 1);
        vm.expectRevert(StoryNotEnabled.selector);
        contractNoStory.addCreatorStory(1, "XCOPY", "I AM XCOPY");
    }

    function testTransferAndAddStory() public {
        // contract with story
        vm.prank(accounts[0], accounts[0]);
        contractWithStory.transferFrom(accounts[0], accounts[1], 1);
        vm.expectEmit(true, true, false, true, address(contractWithStory));
        emit Story(1, accounts[1], "NOT XCOPY", "I AM NOT XCOPY");
        vm.prank(accounts[1], accounts[1]);
        contractWithStory.addStory(1, "NOT XCOPY", "I AM NOT XCOPY");

        // contract no story
        vm.prank(accounts[0], accounts[0]);
        contractNoStory.transferFrom(accounts[0], accounts[1], 1);
        vm.expectRevert(StoryNotEnabled.selector);
        vm.prank(accounts[1], accounts[1]);
        contractNoStory.addStory(1, "NOT XCOPY", "I AM NOT XCOPY");
    }

    ///////////////////// MAX GAS TESTS /////////////////////

    function test5000WordGasEstimate() public {
        string memory story = vm.readFile("test/file_utils/lorem.txt");

        contractWithStory.addCreatorStory(1, "Socrates", story);
    }

    function testFuzzGas(string calldata story) public {
        contractWithStory.addCreatorStory(1, "Socrates", story);
    }
}
