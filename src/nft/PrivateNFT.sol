// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PrivateNFT is Context, ERC721 {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIdTracker;

  /* tokenId => state => uri */
  mapping(uint256 => string) private _uris;
  mapping(uint256 => mapping(address => bool)) private _lease;

  constructor() ERC721("Private", "PNFT") {}

  function mint(string calldata uri) external {
    uint256 currentTokenId = _tokenIdTracker.current();
    _tokenIdTracker.increment();
    _uris[currentTokenId] = uri;
    _safeMint(_msgSender(), currentTokenId);
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    require(_lease[tokenId][_msgSender()], "needs an active lease");
    return _uris[tokenId];
  }

  // lease doesn't get reset on token transfer.
  function lease(address to, uint256 tokenId) external {
    require(ownerOf(tokenId) == msg.sender, "not token owner");
    _lease[tokenId][to] = true;
  }
}
