// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.8.17;

import "OpenZeppelin/openzeppelin-contracts@4.7.3/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.3/contracts/access/Ownable.sol";
import "./StoryContract.sol";

contract Example721 is ERC721, StoryContract, Ownable {

    //================= State Variables =================//
    uint256 private _counter;

    //================= Constructor =================//
    constructor(bool enabled) ERC721("Test", "TST") StoryContract(enabled) Ownable() {}

    //================= Mint =================//
    function mint(uint256 numToMint) external onlyOwner {
        for (uint256 i = 0; i < numToMint; i++) {
            _counter++;
            _mint(msg.sender, _counter);
        }
    }

    //================= Story Implementation =================//
    function _tokenExists(uint256 tokenId) internal view override(StoryContract) returns (bool) {
        return _exists(tokenId);
    }

    function _isTokenOwner(address potentialOwner, uint256 tokenId) internal view override(StoryContract) returns (bool) {
        return ownerOf(tokenId) == potentialOwner;
    } 

    //================= ERC165 =================//
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, StoryContract) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || StoryContract.supportsInterface(interfaceId);
    }
    
}