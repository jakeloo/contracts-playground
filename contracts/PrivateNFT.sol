// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IDataFeed.sol";

contract PrivateNFT is Context, ERC721 {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIdTracker;

  IDataFeed public immutable feed;

  /* tokenId => state => uri */
  mapping(uint256 => string) private _uris;
  mapping(uint256 => mapping(address => bool)) private _lease;

  constructor(address _feed) ERC721("Dynamic", "DNFT") {
    feed = IDataFeed(_feed);
  }

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

  function lease(address to, uint256 tokenId) external {
    _lease[tokenId][to] = true;
  }
}
