from brownie import Example721, accounts, reverts
import pytest

@pytest.fixture()
def story_contract():
    contract = Example721.deploy(True, {"from": accounts[0]})
    contract.mint(3, {"from": accounts[0]})
    contract.transferFrom(accounts[0].address, accounts[1].address, 2)
    contract.transferFrom(accounts[0].address, accounts[2].address, 3)
    return contract

@pytest.fixture()
def non_story_contract():
    contract = Example721.deploy(False, {"from": accounts[0]})
    contract.mint(3, {"from": accounts[0]})
    contract.transferFrom(accounts[0].address, accounts[1].address, 2)
    contract.transferFrom(accounts[0].address, accounts[2].address, 3)
    return contract

##################### View Function #####################
def test_enabled_story_contract(story_contract):
    assert story_contract.storyEnabled()

def test_enabled_non_story_contract(non_story_contract):
    assert not non_story_contract.storyEnabled()

##################### Creator Stories #####################
def test_non_story_contract_creator_story(non_story_contract):
    with reverts("StoryContract: story addition is not enabled"):
        non_story_contract.addCreatorStory(1, "XCOPY", "I AM XCOPY", {"from": accounts[0]})
        non_story_contract.addCreatorStory(2, "XCOPY", "I AM XCOPY", {"from": accounts[0]})
        non_story_contract.addCreatorStory(3, "XCOPY", "I AM XCOPY", {"from": accounts[0]})

def test_story_contract_creator_story(story_contract):
    story_success = True
    for i in range(1, 4):
        tx = story_contract.addCreatorStory(i, "XCOPY", "I AM XCOPY", {"from": accounts[0]})
        story_success = (
            story_success and
            "CreatorStory" in tx.events and
            tx.events["CreatorStory"]["tokenId"] == i and
            tx.events["CreatorStory"]["creatorAddress"] == accounts[0].address and
            tx.events["CreatorStory"]["creatorName"] == "XCOPY" and
            tx.events["CreatorStory"]["story"] == "I AM XCOPY"
        )
    assert story_success

def test_story_contract_nonexistent_token(story_contract):
    with reverts("StoryContract: token does not exist"):
        story_contract.addCreatorStory(4, "XCOPY", "I AM XCOPY", {"from": accounts[0]})

##################### Collector Stories #####################
def test_non_story_contract_story(non_story_contract):
    with reverts("StoryContract: story addition is not enabled"):
        non_story_contract.addStory(1, "XCOPY", "I AM XCOPY", {"from": accounts[0]})
        non_story_contract.addStory(2, "NOT XCOPY", "I AM NOT XCOPY", {"from": accounts[1]})
        non_story_contract.addStory(3, "NOT XCOPY", "I AM NOT XCOPY", {"from": accounts[2]})

def test_story_contract_story(story_contract):
    story_success = True
    for i in range(1, 4):
        tx = story_contract.addStory(i, "NOT XCOPY", "I AM NOT XCOPY", {"from": accounts[i-1]})
        story_success = (
            story_success and
            "Story" in tx.events and
            tx.events["Story"]["tokenId"] == i and
            tx.events["Story"]["collectorAddress"] == accounts[i-1].address and
            tx.events["Story"]["collectorName"] == "NOT XCOPY" and
            tx.events["Story"]["story"] == "I AM NOT XCOPY"
        )
    assert story_success

def test_story_contract_not_token_owner(story_contract):
    for i in range(1, 4):
        with reverts("StoryContract: caller is not token owner"):
            story_contract.addStory(i, "NOT XCOPY", "I AM NOT XCOPY", {"from": accounts[i]})

##################### ERC165 #####################
def test_interface_id_story_contract(story_contract):
    assert story_contract.supportsInterface("0xd23ecb9")

def test_interface_id_non_story_contract(non_story_contract):
    assert non_story_contract.supportsInterface("0xd23ecb9")


##################### Gas Costs #####################
def test_5000_word_story_gas_cost(story_contract):
    story = "Lorem Ipsum" * 2500
    story_contract.addCreatorStory(1, "XCOPY", story, {"from": accounts[0]})
    story_contract.addStory(2, "NOT XCOPY", story, {"from": accounts[1]})