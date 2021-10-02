// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "./interfaces/IDataFeed.sol";

contract DynamicNFT is Context, ERC721, Multicall {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIdTracker;

  IDataFeed public immutable feed;

  /* tokenId => state */
  mapping(uint256 => bytes32) private _initialState;

  /* tokenId => state => uri */
  mapping(uint256 => mapping(bytes32 => string)) private _uris;

  constructor(address _feed) ERC721("Dynamic", "DNFT") {
    feed = IDataFeed(_feed);
  }

  function mint(bytes32[] calldata states, string[] calldata uris) external {
    require(states.length == uris.length, "states.length != uris.length");

    uint256 currentTokenId = _tokenIdTracker.current();

    for (uint256 i = 0; i < states.length; i++) {
      _uris[currentTokenId][states[i]] = uris[i];
    }

    _tokenIdTracker.increment();
    _safeMint(_msgSender(), currentTokenId);
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    bytes32 currentState = feed.data(tokenId);
    if (currentState == "") {
      currentState = _initialState[tokenId];
    }
    string memory uri = _uris[tokenId][currentState];
    return uri;
  }
}
