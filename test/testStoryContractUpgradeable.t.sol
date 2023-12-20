// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {IStory} from "src/IStory.sol";
import {StoryContractUpgradeable} from "src/upgradeable/StoryContractUpgradeable.sol";
import {Example721Upgradeable} from "test/mocks/Example721Upgradeable.sol";

contract StoryContractUpgradeableTest is Test {
    address[] public accounts;
    Example721Upgradeable public contractWithStory;
    Example721Upgradeable public contractNoStory;

    event CollectionStory(address indexed creatorAddress, string creatorName, string story);
    event CreatorStory(uint256 indexed tokenId, address indexed creatorAddress, string creatorName, string story);
    event Story(uint256 indexed tokenId, address indexed collectorAddress, string collectorName, string story);

    function setUp() public {
        accounts.push(makeAddr("account0"));
        accounts.push(makeAddr("account1"));
        accounts.push(makeAddr("account2"));

        contractWithStory = new Example721Upgradeable();
        contractWithStory.initialize(true);
        contractWithStory.mint(4);
        contractWithStory.transferFrom(address(this), accounts[0], 1);
        contractWithStory.transferFrom(address(this), accounts[1], 2);
        contractWithStory.transferFrom(address(this), accounts[2], 3);

        contractNoStory = new Example721Upgradeable();
        contractNoStory.initialize(false);
        contractNoStory.mint(4);
        contractNoStory.transferFrom(address(this), accounts[0], 1);
        contractNoStory.transferFrom(address(this), accounts[1], 2);
        contractNoStory.transferFrom(address(this), accounts[2], 3);
    }

    function test_StoryEnabledOrDisabled() public {
        assertTrue(contractWithStory.storyEnabled());
        assertFalse(contractNoStory.storyEnabled());
    }

    function test_ExpectRevertCannotInitializeAgain() public {
        vm.expectRevert();
        contractWithStory.initialize(true);

        vm.expectRevert();
        contractNoStory.initialize(false);
    }

    function test_Ownership() public {
        assertEq(contractWithStory.owner(), address(this));
        assertEq(contractNoStory.owner(), address(this));
    }

    function test_SetStoryEnabled(bool enabled) public {
        contractWithStory.setStoryEnabled(enabled);
        assertEq(contractWithStory.storyEnabled(), enabled);
        contractNoStory.setStoryEnabled(enabled);
        assertEq(contractNoStory.storyEnabled(), enabled);
    }

    function test_SetStoryEnabledNotAllowed(address addy) public {
        if (addy != address(this)) {
            vm.startPrank(addy, addy);

            vm.expectRevert(StoryContractUpgradeable.NotStoryAdmin.selector);
            contractWithStory.setStoryEnabled(false);

            vm.expectRevert(StoryContractUpgradeable.NotStoryAdmin.selector);
            contractNoStory.setStoryEnabled(true);

            vm.stopPrank();
        }
    }

    function test_ERC165() public {
        assertTrue(contractWithStory.supportsInterface(type(IStory).interfaceId));
        assertTrue(contractWithStory.supportsInterface(0x0d23ecb9)); // previous IStory interfaceId
        assertTrue(contractNoStory.supportsInterface(type(IStory).interfaceId));
        assertTrue(contractNoStory.supportsInterface(0x0d23ecb9)); // previous IStory interfaceId
    }

    function test_AddCollectionStory() public {
        vm.expectEmit(true, false, false, true, address(contractWithStory));
        emit CollectionStory(address(this), "XCOPY", "I AM XCOPY");
        contractWithStory.addCollectionStory("XCOPY", "I AM XCOPY");
    }

    function test_ExpectRevertAddCollectionStory() public {
        // revert for not being the token creator
        for (uint256 i = 0; i < 3; i++) {
            vm.prank(accounts[i], accounts[i]);
            vm.expectRevert(StoryContractUpgradeable.NotCreator.selector);
            contractWithStory.addCollectionStory("XCOPY", "I AM XCOPY");
        }
    }

    function test_AddCreatorStory() public {
        for (uint256 i = 0; i < 4; i++) {
            uint256 id = i + 1;
            vm.expectEmit(true, true, false, true, address(contractWithStory));
            emit CreatorStory(id, address(this), "XCOPY", "I AM XCOPY");
            contractWithStory.addCreatorStory(id, "XCOPY", "I AM XCOPY");
        }
    }

    function test_ExpectRevertAddCreatorStory() public {
        // revert for not being the token creator
        for (uint256 i = 0; i < 3; i++) {
            uint256 id = i + 1;

            vm.prank(accounts[i], accounts[i]);
            vm.expectRevert(StoryContractUpgradeable.NotCreator.selector);
            contractWithStory.addCreatorStory(id, "XCOPY", "I AM XCOPY");
        }

        // revert for not being a token that exists
        vm.expectRevert(StoryContractUpgradeable.TokenDoesNotExist.selector);
        contractWithStory.addCreatorStory(5, "XCOPY", "I AM XCOPY");
    }

    function test_AddStory() public {
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

    function test_ExpectRevertAddStory() public {
        // revert for not being the token owner
        for (uint256 i = 0; i < 3; i++) {
            uint256 id = i + 1;

            vm.expectRevert(StoryContractUpgradeable.NotTokenOwner.selector);
            contractWithStory.addStory(id, "NOT XCOPY", "I AM NOT XCOPY");
        }

        // revert for not being a token that exists
        vm.expectRevert(StoryContractUpgradeable.TokenDoesNotExist.selector);
        contractWithStory.addStory(5, "NOT XCOPY", "I AM NOT XCOPY");
    }

    function test_ExpectEmitDisabledAddCollectionStory() public {
        vm.expectEmit(true, false, false, true, address(contractWithStory));
        emit CollectionStory(address(this), "XCOPY", "I AM XCOPY");
        contractWithStory.addCollectionStory("XCOPY", "I AM XCOPY");
    }

    function test_ExpectEmitDisabledAddCreatorStory() public {
        for (uint256 i = 0; i < 4; i++) {
            uint256 id = i + 1;
            vm.expectEmit(true, true, false, true, address(contractWithStory));
            emit CreatorStory(id, address(this), "XCOPY", "I AM XCOPY");
            contractWithStory.addCreatorStory(id, "XCOPY", "I AM XCOPY");
        }
    }

    function test_ExpectRevertDisabledAddStory() public {
        for (uint256 i = 0; i < 3; i++) {
            uint256 id = i + 1;

            vm.expectRevert(StoryContractUpgradeable.StoryNotEnabled.selector);
            vm.prank(accounts[i], accounts[i]);
            contractNoStory.addStory(id, "NOT XCOPY", "I AM NOT XCOPY");
        }

        vm.expectRevert(StoryContractUpgradeable.StoryNotEnabled.selector);
        contractNoStory.addStory(4, "NOT XCOPY", "I AM NOT XCOPY");
    }

    function test_TransferAndAddCreatorStory() public {
        // contract with story
        vm.prank(accounts[0], accounts[0]);
        contractWithStory.transferFrom(accounts[0], accounts[1], 1);
        vm.expectEmit(true, true, false, true, address(contractWithStory));
        emit CreatorStory(1, address(this), "XCOPY", "I AM XCOPY");
        contractWithStory.addCreatorStory(1, "XCOPY", "I AM XCOPY");

        // contract no story
        vm.prank(accounts[0], accounts[0]);
        contractNoStory.transferFrom(accounts[0], accounts[1], 1);
        vm.expectEmit(true, true, false, true, address(contractNoStory));
        emit CreatorStory(1, address(this), "XCOPY", "I AM XCOPY");
        contractNoStory.addCreatorStory(1, "XCOPY", "I AM XCOPY");
    }

    function test_TransferAndAddStory() public {
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
        vm.expectRevert(StoryContractUpgradeable.StoryNotEnabled.selector);
        vm.prank(accounts[1], accounts[1]);
        contractNoStory.addStory(1, "NOT XCOPY", "I AM NOT XCOPY");
    }

    function test_5000WordGasEstimate() public {
        string memory story = vm.readFile("test/file_utils/lorem.txt");

        contractWithStory.addCreatorStory(1, "Socrates", story);
    }

    function test_FuzzGas(string calldata story) public {
        contractWithStory.addCreatorStory(1, "Socrates", story);
    }
}
