// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * delay reveal. use any source of random to generate seed.
 * seed is used to pick a random base token uri AND as a shifter for token id for token uri.
 * assumption: all nfts reveal at once, for now at least.
 */
contract DelayedNFT is ERC721 {
  using Strings for uint256;

  uint256 public immutable maxSupply = 10000;

  string[] public baseTokenUris;
  uint256 public baseTokenUriIndex;

  bytes32 public seed;
  uint256[] public pivotIndex;

  address public owner;

  constructor() ERC721("Delayed NFT", "NFT") {
    owner = msg.sender;
  }

  /// @dev to be called by trusted node to provide a seed value as a randomizer
  function reveal(bytes32 _seed) external {
    require(msg.sender == owner);
    require(seed == "");
    seed = _seed;

    uint256 count = baseTokenUris.length - 1;
    uint256 selectedBaseUriIndex = uint256(seed) % count;

    // + 1, so the minimum is 1+ to account for unrevealed token uri which is 0
    baseTokenUriIndex = selectedBaseUriIndex + 1;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    uint256 shiftedTokenId = tokenId;

    // algorithm for shifting uri, deterministic
    shiftedTokenId += uint256(seed);

    // 0 indexed. 99 % 100 = 99, 100 % 100 = 0.
    shiftedTokenId = shiftedTokenId % maxSupply;

    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, shiftedTokenId.toString())) : "";
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseTokenUris[baseTokenUriIndex];
  }
}
